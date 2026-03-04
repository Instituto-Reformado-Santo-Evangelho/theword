#!/usr/bin/perl -w

package TheWord::Logger;

use v5.30;
use strict;
use warnings;
use Cwd;
use POSIX qw(strftime);
use File::Path qw(make_path);

our $VERSION = '1.0.0';

# Níveis de log
use constant {
    LEVEL_DEBUG => 0,
    LEVEL_INFO  => 1,
    LEVEL_WARN  => 2,
    LEVEL_ERROR => 3,
    LEVEL_FATAL => 4,
};

# Cores para output
use constant {
    COLOR_DEBUG => "\033[0;36m",  # Cyan
    COLOR_INFO  => "\033[0;32m",  # Green
    COLOR_WARN  => "\033[0;33m",  # Yellow
    COLOR_ERROR => "\033[0;31m",  # Red
    COLOR_FATAL => "\033[1;31m",  # Bold Red
    COLOR_RESET => "\033[0m",     # Reset
};

# Construtor
sub new {
    my ($class, %args) = @_;
    
    # Criar diretório de logs se não existir
    my $log_dir = getcwd . "/logs";
    make_path($log_dir) unless -d $log_dir;
    
    my $self = {
        log_level => $args{level} // LEVEL_INFO,
        log_file => $args{file} // $log_dir . "/theword.log",
        console_output => $args{console} // 1,
        colors => $args{colors} // 1,
        timestamp_format => $args{timestamp} // "%Y-%m-%d %H:%M:%S",
    };
    
    bless $self, $class;
    
    # Inicializar arquivo de log
    $self->_init_log_file();
    
    return $self;
}

# Inicializar arquivo de log
sub _init_log_file {
    my ($self) = @_;
    
    # Criar arquivo de log se não existir
    if (!-f $self->{log_file}) {
        open(my $fh, '>', $self->{log_file}) or die "Não foi possível criar arquivo de log: $!";
        close $fh;
    }
    
    # Log de inicialização
    $self->_write_log(LEVEL_INFO, "=== Logger iniciado ===");
}

# Método para debug
sub debug {
    my ($self, $message) = @_;
    $self->_write_log(LEVEL_DEBUG, $message);
}

# Método para info
sub info {
    my ($self, $message) = @_;
    $self->_write_log(LEVEL_INFO, $message);
}

# Método para warning
sub warn {
    my ($self, $message) = @_;
    $self->_write_log(LEVEL_WARN, $message);
}

# Método para error
sub error {
    my ($self, $message) = @_;
    $self->_write_log(LEVEL_ERROR, $message);
}

# Método para fatal
sub fatal {
    my ($self, $message) = @_;
    $self->_write_log(LEVEL_FATAL, $message);
    die "FATAL: $message\n";
}

# Método interno para escrever log
sub _write_log {
    my ($self, $level, $message) = @_;
    
    # Verificar se deve logar baseado no nível
    return if $level < $self->{log_level};
    
    my $timestamp = strftime($self->{timestamp_format}, localtime);
    my $level_name = $self->_get_level_name($level);
    my $log_line = "[$timestamp] [$level_name] $message\n";
    
    # Escrever no arquivo
    if (open(my $fh, '>>', $self->{log_file})) {
        print $fh $log_line;
        close $fh;
    }
    
    # Escrever no console se habilitado
    if ($self->{console_output}) {
        my $console_line = $log_line;
        
        # Adicionar cores se habilitado
        if ($self->{colors}) {
            my $color = $self->_get_level_color($level);
            $console_line = $color . $log_line . COLOR_RESET;
        }
        
        print $console_line;
    }
}

# Obter nome do nível
sub _get_level_name {
    my ($self, $level) = @_;
    
    my %level_names = (
        LEVEL_DEBUG() => 'DEBUG',
        LEVEL_INFO()  => 'INFO ',
        LEVEL_WARN()  => 'WARN ',
        LEVEL_ERROR() => 'ERROR',
        LEVEL_FATAL() => 'FATAL',
    );
    
    return $level_names{$level} // 'UNKN ';
}

# Obter cor do nível
sub _get_level_color {
    my ($self, $level) = @_;
    
    my %level_colors = (
        LEVEL_DEBUG() => COLOR_DEBUG,
        LEVEL_INFO()  => COLOR_INFO,
        LEVEL_WARN()  => COLOR_WARN,
        LEVEL_ERROR() => COLOR_ERROR,
        LEVEL_FATAL() => COLOR_FATAL,
    );
    
    return $level_colors{$level} // '';
}

# Método para mudar nível de log dinamicamente
sub set_level {
    my ($self, $level) = @_;
    $self->{log_level} = $level;
    $self->info("Nível de log alterado para: " . $self->_get_level_name($level));
}

# Método para obter estatísticas do log
sub get_stats {
    my ($self) = @_;
    
    return {} unless -f $self->{log_file};
    
    open(my $fh, '<', $self->{log_file}) or return {};
    my @lines = <$fh>;
    close $fh;
    
    my %stats = (
        total_lines => scalar @lines,
        debug_count => 0,
        info_count => 0,
        warn_count => 0,
        error_count => 0,
        fatal_count => 0,
    );
    
    for my $line (@lines) {
        $stats{debug_count}++ if $line =~ /\[DEBUG\]/;
        $stats{info_count}++  if $line =~ /\[INFO \]/;
        $stats{warn_count}++  if $line =~ /\[WARN \]/;
        $stats{error_count}++ if $line =~ /\[ERROR\]/;
        $stats{fatal_count}++ if $line =~ /\[FATAL\]/;
    }
    
    return \%stats;
}

# Método para limpar log antigo
sub rotate_log {
    my ($self, $keep_days) = @_;
    $keep_days //= 30;
    
    my $backup_file = $self->{log_file} . "." . strftime("%Y%m%d", localtime);
    
    # Mover log atual para backup
    if (-f $self->{log_file}) {
        rename $self->{log_file}, $backup_file;
        $self->_init_log_file();
        $self->info("Log rotacionado para: $backup_file");
    }
    
    # Limpar logs antigos
    my $log_dir = (File::Spec->splitpath($self->{log_file}))[1];
    my $cutoff_time = time - ($keep_days * 24 * 60 * 60);
    
    opendir(my $dh, $log_dir) or return;
    while (my $file = readdir($dh)) {
        next unless $file =~ /^theword\.log\.\d{8}$/;
        my $full_path = File::Spec->catfile($log_dir, $file);
        my $mtime = (stat($full_path))[9];
        if ($mtime < $cutoff_time) {
            unlink $full_path;
            $self->info("Log antigo removido: $file");
        }
    }
    closedir($dh);
}

# Método para timestamp customizado
sub timestamp {
    my ($self, $format) = @_;
    $format //= $self->{timestamp_format};
    return strftime($format, localtime);
}

1;

__END__

=head1 NAME

TheWord::Logger - Sistema de logging para scripts TheWord

=head1 SYNOPSIS

    use TheWord::Logger;
    
    my $logger = TheWord::Logger->new(
        level => TheWord::Logger::LEVEL_DEBUG,
        file => "/path/to/custom.log",
        console => 1,
        colors => 1
    );
    
    $logger->info("Iniciando processamento");
    $logger->warn("Arquivo pode estar vazio");
    $logger->error("Erro ao processar versículo");
    $logger->debug("Variável X = $x");

=head1 DESCRIPTION

Sistema de logging robusto com suporte a diferentes níveis, cores no console,
rotação automática de logs e estatísticas.

=head1 METHODS

=head2 new(%args)

Cria uma nova instância do logger com opções configuráveis.

=head2 debug($message)

Log de nível debug (mais detalhado).

=head2 info($message)

Log de nível informativo.

=head2 warn($message)

Log de nível warning (aviso).

=head2 error($message)

Log de nível error (erro).

=head2 fatal($message)

Log de nível fatal (termina execução).

=head2 set_level($level)

Altera dinamicamente o nível de log.

=head2 get_stats()

Retorna estatísticas do arquivo de log.

=head2 rotate_log($keep_days)

Rotaciona o log atual e remove logs antigos.

=head1 AUTHOR

Instituto Reformado Santo Evangelho

=head1 COPYRIGHT

Copyright (c) 2025. Todos os direitos reservados.

=cut