#!/usr/bin/perl -w

package TheWord::Encoding;

use v5.30;
use strict;
use warnings;
use Encode qw(encode decode);
use File::Copy qw(copy);

our $VERSION = '1.0.0';

# BOM UTF-8: EF BB BF
our $UTF8_BOM = "\xEF\xBB\xBF";

# Construtor
sub new {
    my ($class, %args) = @_;
    
    my $self = {
        debug => $args{debug} // 0,
        backup => $args{backup} // 1,
    };
    
    return bless $self, $class;
}

# Verificar se arquivo tem BOM UTF-8
sub has_utf8_bom {
    my ($self, $file) = @_;
    
    return 0 unless -f $file;
    
    open(my $fh, '<:raw', $file) or return 0;
    my $bom;
    read($fh, $bom, 3);
    close $fh;
    
    return $bom eq $UTF8_BOM;
}

# Ler arquivo com tratamento correto de BOM
sub read_file_utf8_bom {
    my ($self, $file) = @_;
    
    die "Arquivo não encontrado: $file" unless -f $file;
    
    # Ler arquivo raw primeiro
    open(my $fh, '<:raw', $file) or die "Erro ao abrir $file: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    
    # Verificar e remover BOM se presente
    if (substr($content, 0, 3) eq $UTF8_BOM) {
        $content = substr($content, 3);
        $self->debug_print("BOM UTF-8 detectado e removido de $file");
    } else {
        $self->debug_print("⚠️  BOM UTF-8 NÃO encontrado em $file");
    }
    
    # Decodificar para UTF-8
    return decode('UTF-8', $content);
}

# Escrever arquivo com BOM UTF-8
sub write_file_utf8_bom {
    my ($self, $file, $content) = @_;
    
    # Fazer backup se solicitado
    if ($self->{backup} && -f $file) {
        my $backup = "$file.bak.utf8";
        copy($file, $backup);
        $self->debug_print("Backup criado: $backup");
    }
    
    # Codificar conteúdo para UTF-8
    my $utf8_content = encode('UTF-8', $content);
    
    # Escrever com BOM
    open(my $fh, '>:raw', $file) or die "Erro ao criar $file: $!";
    print $fh $UTF8_BOM;  # Escrever BOM primeiro
    print $fh $utf8_content;
    close $fh;
    
    $self->debug_print("✅ Arquivo salvo com BOM UTF-8: $file");
    
    # Verificar se foi salvo corretamente
    unless ($self->has_utf8_bom($file)) {
        die "❌ Falha ao salvar com BOM UTF-8: $file";
    }
    
    return 1;
}

# Converter arquivo para UTF-8 com BOM
sub convert_to_utf8_bom {
    my ($self, $file) = @_;
    
    die "Arquivo não encontrado: $file" unless -f $file;
    
    if ($self->has_utf8_bom($file)) {
        $self->debug_print("✅ $file já tem BOM UTF-8");
        return 1;
    }
    
    $self->debug_print("🔄 Convertendo $file para UTF-8 com BOM...");
    
    # Ler conteúdo atual
    my $content = $self->read_file_utf8_bom($file);
    
    # Reescrever com BOM
    $self->write_file_utf8_bom($file, $content);
    
    $self->debug_print("✅ Conversão concluída: $file");
    return 1;
}

# Validar codificação de múltiplos arquivos
sub validate_encoding {
    my ($self, @files) = @_;
    
    my @results;
    
    for my $file (@files) {
        my $result = {
            file => $file,
            exists => -f $file,
            has_bom => 0,
            is_utf8 => 0,
            valid => 0,
            size => 0,
        };
        
        if ($result->{exists}) {
            $result->{has_bom} = $self->has_utf8_bom($file);
            $result->{size} = -s $file;
            
            # Tentar ler como UTF-8
            eval {
                my $content = $self->read_file_utf8_bom($file);
                $result->{is_utf8} = 1;
            };
            
            $result->{valid} = $result->{has_bom} && $result->{is_utf8};
        }
        
        push @results, $result;
    }
    
    return \@results;
}

# Corrigir codificação de arquivos TheWord
sub fix_theword_encoding {
    my ($self, @files) = @_;
    
    my @fixed = ();
    my @errors = ();
    
    for my $file (@files) {
        eval {
            if ($self->convert_to_utf8_bom($file)) {
                push @fixed, $file;
            }
        };
        
        if ($@) {
            push @errors, { file => $file, error => $@ };
        }
    }
    
    return {
        fixed => \@fixed,
        errors => \@errors,
        total_processed => scalar @files,
        success_count => scalar @fixed,
        error_count => scalar @errors,
    };
}

# Mostrar relatório de codificação
sub encoding_report {
    my ($self, $validation_results) = @_;
    
    my $report = "\n📊 RELATÓRIO DE CODIFICAÇÃO UTF-8 BOM\n";
    $report .= "=" x 50 . "\n";
    
    my ($valid, $invalid, $missing) = (0, 0, 0);
    
    for my $result (@$validation_results) {
        my $status;
        
        if (!$result->{exists}) {
            $status = "❌ NÃO EXISTE";
            $missing++;
        } elsif ($result->{valid}) {
            $status = "✅ UTF-8 BOM";
            $valid++;
        } elsif ($result->{has_bom} && !$result->{is_utf8}) {
            $status = "⚠️  BOM mas não UTF-8";
            $invalid++;
        } elsif (!$result->{has_bom} && $result->{is_utf8}) {
            $status = "⚠️  UTF-8 sem BOM";
            $invalid++;
        } else {
            $status = "❌ INVÁLIDO";
            $invalid++;
        }
        
        $report .= sprintf("%-20s %s (%d bytes)\n", 
                          $result->{file}, $status, $result->{size});
    }
    
    $report .= "=" x 50 . "\n";
    $report .= sprintf("✅ Válidos: %d | ⚠️  Inválidos: %d | ❌ Ausentes: %d\n", 
                      $valid, $invalid, $missing);
    
    return $report;
}

# Gerar BOM em hexadecimal (para debug)
sub get_bom_hex {
    my ($self) = @_;
    return join(' ', map { sprintf('%02X', ord($_)) } split //, $UTF8_BOM);
}

# Verificar se sistema suporta UTF-8
sub check_system_utf8_support {
    my ($self) = @_;
    
    my $support = {
        perl_version => $],
        encode_module => eval { require Encode; 1 } // 0,
        utf8_locale => ($ENV{LC_ALL} || $ENV{LANG} || '') =~ /utf-?8/i,
        file_test => 0,
    };
    
    # Teste prático de escrita/leitura
    eval {
        my $test_file = "/tmp/utf8_bom_test.tmp";
        $self->write_file_utf8_bom($test_file, "Teste UTF-8: ção, ã, ñ, é");
        my $content = $self->read_file_utf8_bom($test_file);
        unlink $test_file;
        $support->{file_test} = ($content =~ /ção/);
    };
    
    return $support;
}

# Debug print
sub debug_print {
    my ($self, $message) = @_;
    print "$message\n" if $self->{debug};
}

1;

__END__

=head1 NAME

TheWord::Encoding - Gerenciamento de codificação UTF-8 com BOM para TheWord

=head1 SYNOPSIS

    use TheWord::Encoding;
    
    my $encoder = TheWord::Encoding->new(debug => 1);
    
    # Verificar se arquivo tem BOM UTF-8
    if ($encoder->has_utf8_bom('arquivo.nt')) {
        print "Arquivo tem BOM UTF-8\n";
    }
    
    # Ler arquivo com tratamento de BOM
    my $content = $encoder->read_file_utf8_bom('arquivo.nt');
    
    # Escrever arquivo com BOM UTF-8
    $encoder->write_file_utf8_bom('arquivo.nt', $content);
    
    # Validar múltiplos arquivos
    my $results = $encoder->validate_encoding(@files);
    print $encoder->encoding_report($results);

=head1 DESCRIPTION

Este módulo garante que todos os arquivos TheWord (.nt) tenham a codificação
UTF-8 com BOM (Byte Order Mark) necessária para a exibição correta de acentos
e caracteres especiais no software TheWord.

=head1 WHY UTF-8 BOM?

O software TheWord requer UTF-8 com BOM para:
- Exibição correta de acentos (á, ã, ç, etc.)
- Caracteres especiais portugueses/latinos
- Compatibilidade com versões antigas do TheWord
- Detecção automática de codificação

=head1 METHODS

=head2 new(%args)

Cria nova instância do codificador.

=head2 has_utf8_bom($file)

Verifica se arquivo tem BOM UTF-8 (EF BB BF).

=head2 read_file_utf8_bom($file)

Lê arquivo removendo BOM e decodificando como UTF-8.

=head2 write_file_utf8_bom($file, $content)

Escreve arquivo com BOM UTF-8 obrigatório.

=head2 validate_encoding(@files)

Valida codificação de múltiplos arquivos.

=head2 encoding_report($results)

Gera relatório legível de validação.

=head1 AUTHOR

Instituto Reformado Santo Evangelho

=head1 COPYRIGHT

Copyright (c) 2025. Todos os direitos reservados.

=cut