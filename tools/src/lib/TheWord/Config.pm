#!/usr/bin/perl -w

package TheWord::Config;

use v5.30;
use strict;
use warnings;
use utf8;
use Cwd;
use File::Path qw(make_path);
use File::Spec;

our $VERSION = '1.0.0';

# Construtor
sub new {
    my ($class, %args) = @_;
    
    my $config_dir = getcwd . "/config";
    make_path($config_dir) unless -d $config_dir;
    
    my $self = {
        config_dir => $config_dir,
        books_file => $config_dir . "/books.conf",
        main_config_file => $config_dir . "/theword.conf",
        _books_cache => {},
        _config_cache => {},
    };
    
    bless $self, $class;
    
    # Inicializar arquivos de configuração se não existirem
    $self->_init_config_files();
    
    return $self;
}

# Inicializar arquivos de configuração
sub _init_config_files {
    my ($self) = @_;
    
    # Criar arquivo de livros se não existir
    if (!-f $self->{books_file}) {
        $self->_create_default_books_config();
    }
    
    # Criar arquivo de configuração principal se não existir
    if (!-f $self->{main_config_file}) {
        $self->_create_default_main_config();
    }
}

# Criar configuração padrão de livros
sub _create_default_books_config {
    my ($self) = @_;
    
    my $default_books = <<'EOF';
# Configuração de Livros - TheWord Família 35
# Formato: nome_completo|abreviação|código_numerico
# 
# Novo Testamento

# Evangelhos
mateus|Mt|40
marcos|Mc|41
lucas|Lc|42
joão|Jo|43

# História
atos|At|44

# Cartas Paulinas
romanos|Rm|45
1coríntios|1Co|46
2coríntios|2Co|47
gálatas|Gl|48
efésios|Ef|49
filipenses|Fp|50
colossenses|Cl|51
1tessalonicenses|1Ts|52
2tessalonicenses|2Ts|53
1timóteo|1Tm|54
2timóteo|2Tm|55
tito|Tt|56
filemom|Fm|57

# Cartas Gerais
hebreus|Hb|58
tiago|Tg|59
1pedro|1Pe|60
2pedro|2Pe|61
1joão|1Jo|62
2joão|2Jo|63
3joão|3Jo|64
judas|Jd|65

# Profético
apocalipse|Ap|66
EOF

    open(my $fh, '>', $self->{books_file}) or die "Não foi possível criar arquivo de livros: $!";
    print $fh $default_books;
    close $fh;
}

# Criar configuração principal padrão
sub _create_default_main_config {
    my ($self) = @_;
    
    my $default_config = <<'EOF';
# Configuração Principal - TheWord Família 35
# 
# Diretórios
input_dir=.
output_dir=.
modules_dir=modules/bible/f35
backup_dir=backup
logs_dir=logs

# Arquivos
table_verses_file=perl/table-verses
input_verses_file=input-verses.txt
input_notes_file=input-notes.txt
edit_verses_file=edit-verses.txt
edit_notes_file=edit-notes.txt
merged_file=merged.txt

# Configurações de processamento
auto_backup=true
validate_encoding=true
strict_validation=true
interactive_mode=true

# Configurações de log
log_level=INFO
log_console=true
log_colors=true
log_rotation_days=30

# Configurações de encoding
default_encoding=utf8
detect_encoding=true

# Configurações de interface
show_progress=true
confirm_destructive_operations=true
preview_changes=true

# Tags TheWord
title_tag_1=<TS1>%s<Ts>
title_tag_2=<TS2>%s<Ts>
note_ref_tag=<RF q=%d>%s<Rf>
sup_tag=<sup>%d</sup>

# Limites
max_verses_per_chapter=200
max_notes_per_chapter=100
max_file_size_mb=10
EOF

    open(my $fh, '>', $self->{main_config_file}) or die "Não foi possível criar arquivo de configuração: $!";
    print $fh $default_config;
    close $fh;
}

# Obter livros suportados
sub get_supported_books {
    my ($self) = @_;
    
    # Usar cache se disponível
    return $self->{_books_cache} if %{$self->{_books_cache}};
    
    open(my $fh, '<:utf8', $self->{books_file}) or die "Não foi possível ler arquivo de livros: $!";
    
    my %books;
    while (my $line = <$fh>) {
        chomp $line;
        
        # Pular comentários e linhas vazias
        next if $line =~ /^\s*#/ || $line =~ /^\s*$/;
        
        # Parse da linha: nome|abreviação|código
        if ($line =~ /^([^|]+)\|([^|]+)\|(\d+)$/) {
            my ($name, $abbrev, $code) = ($1, $2, $3);
            $books{lc($name)} = {
                name => $name,
                abbreviation => $abbrev,
                code => $code,
            };
        }
    }
    
    close $fh;
    
    # Cache do resultado
    $self->{_books_cache} = \%books;
    
    return \%books;
}

# Obter abreviação de um livro
sub get_book_abbreviation {
    my ($self, $book_name) = @_;
    
    my $books = $self->get_supported_books();
    my $book_lower = lc($book_name);
    
    return $books->{$book_lower}->{abbreviation} if exists $books->{$book_lower};
    return undef;
}

# Obter código numérico de um livro
sub get_book_code {
    my ($self, $book_name) = @_;
    
    my $books = $self->get_supported_books();
    my $book_lower = lc($book_name);
    
    return $books->{$book_lower}->{code} if exists $books->{$book_lower};
    return undef;
}

# Obter configuração principal
sub get_config {
    my ($self, $key) = @_;
    
    # Carregar configurações se cache vazio
    if (!%{$self->{_config_cache}}) {
        $self->_load_main_config();
    }
    
    return $key ? $self->{_config_cache}->{$key} : $self->{_config_cache};
}

# Carregar configuração principal
sub _load_main_config {
    my ($self) = @_;
    
    open(my $fh, '<:utf8', $self->{main_config_file}) or die "Não foi possível ler configuração principal: $!";
    
    my %config;
    while (my $line = <$fh>) {
        chomp $line;
        
        # Pular comentários e linhas vazias
        next if $line =~ /^\s*#/ || $line =~ /^\s*$/;
        
        # Parse da linha: chave=valor
        if ($line =~ /^([^=]+)=(.*)$/) {
            my ($key, $value) = ($1, $2);
            
            # Converter valores booleanos
            if ($value =~ /^(true|false)$/i) {
                $value = lc($value) eq 'true' ? 1 : 0;
            }
            # Converter valores numéricos
            elsif ($value =~ /^\d+$/) {
                $value = int($value);
            }
            
            $config{$key} = $value;
        }
    }
    
    close $fh;
    
    # Cache do resultado
    $self->{_config_cache} = \%config;
}

# Definir configuração
sub set_config {
    my ($self, $key, $value) = @_;
    
    # Carregar configurações se cache vazio
    if (!%{$self->{_config_cache}}) {
        $self->_load_main_config();
    }
    
    $self->{_config_cache}->{$key} = $value;
}

# Salvar configurações no arquivo
sub save_config {
    my ($self) = @_;
    
    return unless %{$self->{_config_cache}};
    
    # Criar backup da configuração atual
    if (-f $self->{main_config_file}) {
        my $backup_file = $self->{main_config_file} . ".backup";
        rename $self->{main_config_file}, $backup_file;
    }
    
    open(my $fh, '>:utf8', $self->{main_config_file}) or die "Não foi possível salvar configuração: $!";
    
    print $fh "# Configuração Principal - TheWord Família 35\n";
    print $fh "# Atualizada automaticamente em " . scalar(localtime) . "\n\n";
    
    for my $key (sort keys %{$self->{_config_cache}}) {
        my $value = $self->{_config_cache}->{$key};
        
        # Converter booleanos de volta
        if ($value =~ /^[01]$/) {
            $value = $value ? 'true' : 'false';
        }
        
        print $fh "$key=$value\n";
    }
    
    close $fh;
}

# Adicionar novo livro
sub add_book {
    my ($self, $name, $abbreviation, $code) = @_;
    
    # Validar parâmetros
    die "Nome do livro é obrigatório" unless $name;
    die "Abreviação é obrigatória" unless $abbreviation;
    die "Código deve ser numérico" unless $code && $code =~ /^\d+$/;
    
    # Verificar se livro já existe
    my $books = $self->get_supported_books();
    if (exists $books->{lc($name)}) {
        die "Livro '$name' já existe na configuração";
    }
    
    # Adicionar ao arquivo
    open(my $fh, '>>', $self->{books_file}) or die "Não foi possível adicionar livro: $!";
    print $fh "\n# Adicionado automaticamente\n";
    print $fh "$name|$abbreviation|$code\n";
    close $fh;
    
    # Limpar cache para forçar recarregamento
    $self->{_books_cache} = {};
    
    return 1;
}

# Obter paths de arquivos baseados na configuração
sub get_file_path {
    my ($self, $type) = @_;
    
    my $config = $self->get_config();
    my $base_dir = getcwd;
    
    my $input_dir = $config->{input_dir} // '.';
    my $output_dir = $config->{output_dir} // '.';
    
    my %paths = (
        'input_verses' => File::Spec->catfile($input_dir, $config->{input_verses_file} // 'input-verses.txt'),
        'input_notes' => File::Spec->catfile($input_dir, $config->{input_notes_file} // 'input-notes.txt'),
        'edit_verses' => File::Spec->catfile($output_dir, $config->{edit_verses_file} // 'edit-verses.txt'),
        'edit_notes' => File::Spec->catfile($output_dir, $config->{edit_notes_file} // 'edit-notes.txt'),
        'merged' => File::Spec->catfile($output_dir, $config->{merged_file} // 'merged.txt'),
        'table_verses' => $config->{table_verses_file} // 'tools/table-verses',
        'modules_dir' => $config->{modules_dir} // 'modules/bible/f35',
        'backup_dir' => $config->{backup_dir} // 'backup',
        'logs_dir' => $config->{logs_dir} // 'logs',
    );
    
    return File::Spec->rel2abs($paths{$type}, $base_dir) if exists $paths{$type};
    return undef;
}

# Validar configuração
sub validate_config {
    my ($self) = @_;
    my @errors;
    
    # Verificar se arquivos de configuração existem
    push @errors, "Arquivo de livros não encontrado: " . $self->{books_file} unless -f $self->{books_file};
    push @errors, "Arquivo de configuração não encontrado: " . $self->{main_config_file} unless -f $self->{main_config_file};
    
    # Verificar livros
    eval { $self->get_supported_books(); };
    push @errors, "Erro ao carregar livros: $@" if $@;
    
    # Verificar configuração principal
    eval { $self->get_config(); };
    push @errors, "Erro ao carregar configuração: $@" if $@;
    
    return @errors ? \@errors : undef;
}

1;

__END__

=head1 NAME

TheWord::Config - Sistema de configuração para scripts TheWord

=head1 SYNOPSIS

    use TheWord::Config;
    
    my $config = TheWord::Config->new();
    
    # Obter livros suportados
    my $books = $config->get_supported_books();
    
    # Obter abreviação
    my $abbrev = $config->get_book_abbreviation('Lucas');
    
    # Obter configuração
    my $log_level = $config->get_config('log_level');
    
    # Adicionar novo livro
    $config->add_book('Atos', 'At', 44);

=head1 DESCRIPTION

Sistema centralizado de configuração que gerencia livros suportados,
configurações gerais e paths de arquivos.

=head1 METHODS

=head2 new()

Cria uma nova instância do sistema de configuração.

=head2 get_supported_books()

Retorna hash com todos os livros suportados.

=head2 get_book_abbreviation($book_name)

Retorna a abreviação para um livro.

=head2 get_book_code($book_name)

Retorna o código numérico para um livro.

=head2 get_config($key)

Retorna valor de configuração (ou todas se $key não especificado).

=head2 set_config($key, $value)

Define valor de configuração.

=head2 add_book($name, $abbreviation, $code)

Adiciona novo livro à configuração.

=head2 get_file_path($type)

Retorna path completo para um tipo de arquivo.

=head2 validate_config()

Valida a configuração atual.

=head1 AUTHOR

Instituto Reformado Santo Evangelho

=head1 COPYRIGHT

Copyright (c) 2025. Todos os direitos reservados.

=cut