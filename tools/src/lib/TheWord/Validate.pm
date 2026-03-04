#!/usr/bin/perl -w

package TheWord::Validate;

use v5.30;
use strict;
use warnings;
use utf8;
use Cwd;
use File::Basename;
use FindBin qw($RealBin);
use lib "$RealBin";

use TheWord::Logger;
use TheWord::Config;

our $VERSION = '1.0.0';

# Códigos de erro padronizados
use constant {
    ERR_FILE_NOT_FOUND => 1001,
    ERR_FILE_EMPTY => 1002,
    ERR_INVALID_FORMAT => 1003,
    ERR_BOOK_NOT_SUPPORTED => 1004,
    ERR_CHAPTER_INVALID => 1005,
    ERR_VERSE_MISMATCH => 1006,
    ERR_ENCODING_ISSUE => 1007,
    ERR_SYNTAX_ERROR => 1008,
};

# Construtor
sub new {
    my ($class, %args) = @_;
    my $self = {
        logger => TheWord::Logger->new(),
        config => TheWord::Config->new(),
        debug => $args{debug} // 0,
    };
    return bless $self, $class;
}

# Validação de arquivos de entrada
sub validate_input_files {
    my ($self, $verses_file, $notes_file) = @_;
    my $errors = [];
    
    $self->{logger}->info("Validando arquivos de entrada...");
    
    # Verificar existência dos arquivos
    if (!-f $verses_file) {
        push @$errors, {
            code => ERR_FILE_NOT_FOUND,
            message => "Arquivo de versículos não encontrado: $verses_file",
            suggestion => "Certifique-se de que o arquivo input-verses.txt existe no diretório atual"
        };
    }
    
    if (!-f $notes_file) {
        push @$errors, {
            code => ERR_FILE_NOT_FOUND,
            message => "Arquivo de notas não encontrado: $notes_file",
            suggestion => "Certifique-se de que o arquivo input-notes.txt existe no diretório atual"
        };
    }
    
    # Se arquivos existem, verificar se não estão vazios
    if (-f $verses_file && -z $verses_file) {
        push @$errors, {
            code => ERR_FILE_EMPTY,
            message => "Arquivo de versículos está vazio: $verses_file",
            suggestion => "Cole o texto dos versículos do PDF no arquivo input-verses.txt"
        };
    }
    
    if (-f $notes_file && -z $notes_file) {
        push @$errors, {
            code => ERR_FILE_EMPTY,
            message => "Arquivo de notas está vazio: $notes_file",
            suggestion => "Cole as notas de rodapé do PDF no arquivo input-notes.txt"
        };
    }
    
    # Verificar encoding dos arquivos
    if (-f $verses_file) {
        my $encoding_result = $self->_check_encoding($verses_file);
        if (!$encoding_result->{valid}) {
            push @$errors, {
                code => ERR_ENCODING_ISSUE,
                message => "Problema de encoding no arquivo: $verses_file",
                suggestion => "Salve o arquivo como UTF-8"
            };
        }
    }
    
    if (@$errors) {
        $self->{logger}->error("Erros encontrados na validação de arquivos de entrada");
        return { valid => 0, errors => $errors };
    }
    
    $self->{logger}->info("Arquivos de entrada validados com sucesso");
    return { valid => 1, errors => [] };
}

# Validação de parâmetros
sub validate_parameters {
    my ($self, $book_name, $chapter_verses) = @_;
    my $errors = [];
    
    $self->{logger}->info("Validando parâmetros: livro='$book_name', capítulo='$chapter_verses'");
    
    # Verificar se parâmetros foram fornecidos
    if (!defined $book_name || $book_name eq '') {
        push @$errors, {
            code => ERR_INVALID_FORMAT,
            message => "Nome do livro não foi fornecido",
            suggestion => "Use: perl index.pl [NomeLivro] [Capítulo:Versículos]\nExemplo: perl index.pl Lucas 4:1-7"
        };
        return { valid => 0, errors => $errors };
    }
    
    if (!defined $chapter_verses || $chapter_verses eq '') {
        push @$errors, {
            code => ERR_INVALID_FORMAT,
            message => "Capítulo/versículos não foram fornecidos",
            suggestion => "Use: perl index.pl [NomeLivro] [Capítulo:Versículos]\nExemplo: perl index.pl Lucas 4:1-7"
        };
        return { valid => 0, errors => $errors };
    }
    
    # Verificar se livro é suportado
    my $supported_books = $self->{config}->get_supported_books();
    my $book_lower = lc($book_name);
    
    if (!exists $supported_books->{$book_lower}) {
        my $available = join(', ', keys %$supported_books);
        push @$errors, {
            code => ERR_BOOK_NOT_SUPPORTED,
            message => "Livro '$book_name' não é suportado",
            suggestion => "Livros disponíveis: $available"
        };
    }
    
    # Validar formato de capítulo:versículos
    if ($chapter_verses !~ /^\d+(:(\d+(-\d+)?)?)?$/) {
        push @$errors, {
            code => ERR_INVALID_FORMAT,
            message => "Formato inválido para capítulo/versículos: '$chapter_verses'",
            suggestion => "Use formatos como: '4' (capítulo inteiro), '4:1-7' (versículos 1 a 7), '4:30' (30 versículos)"
        };
    } else {
        # Validação adicional se livro é suportado
        if (exists $supported_books->{$book_lower}) {
            my $validation_result = $self->_validate_chapter_verses($book_name, $chapter_verses);
            if (!$validation_result->{valid}) {
                push @$errors, @{$validation_result->{errors}};
            }
        }
    }
    
    if (@$errors) {
        $self->{logger}->error("Erros encontrados na validação de parâmetros");
        return { valid => 0, errors => $errors };
    }
    
    $self->{logger}->info("Parâmetros validados com sucesso");
    return { valid => 1, errors => [] };
}

# Validação de saída
sub validate_output {
    my ($self, $merged_file, $expected_verses, $book_name) = @_;
    my $errors = [];
    
    $self->{logger}->info("Validando arquivo de saída: $merged_file");
    
    if (!-f $merged_file) {
        push @$errors, {
            code => ERR_FILE_NOT_FOUND,
            message => "Arquivo merged.txt não foi gerado",
            suggestion => "Verifique se o processamento foi concluído corretamente"
        };
        return { valid => 0, errors => $errors };
    }
    
    # Contar linhas e validar conteúdo
    open(my $fh, '<:utf8', $merged_file) or do {
        push @$errors, {
            code => ERR_FILE_NOT_FOUND,
            message => "Não foi possível abrir arquivo merged.txt: $!",
            suggestion => "Verifique as permissões do arquivo"
        };
        return { valid => 0, errors => $errors };
    };
    
    my @lines = <$fh>;
    close $fh;
    
    my $line_count = scalar @lines;
    
    # Verificar número de versículos
    if (defined $expected_verses && $line_count != $expected_verses) {
        push @$errors, {
            code => ERR_VERSE_MISMATCH,
            message => "Número de linhas ($line_count) não corresponde ao esperado ($expected_verses)",
            suggestion => "Verifique se todos os versículos foram incluídos no texto de entrada"
        };
    }
    
    # Validar sintaxe TheWord
    my $syntax_errors = $self->_validate_theword_syntax(\@lines);
    if (@$syntax_errors) {
        push @$errors, @$syntax_errors;
    }
    
    # Verificar notas órfãs
    my $orphan_notes = $self->_check_orphan_notes(\@lines);
    if (@$orphan_notes) {
        push @$errors, @$orphan_notes;
    }
    
    if (@$errors) {
        $self->{logger}->error("Erros encontrados na validação de saída");
        return { valid => 0, errors => $errors };
    }
    
    $self->{logger}->info("Arquivo de saída validado com sucesso");
    return { valid => 1, errors => [] };
}

# Métodos privados

sub _check_encoding {
    my ($self, $file) = @_;
    
    # Tentativa simples de detectar problemas de encoding
    open(my $fh, '<:raw', $file) or return { valid => 0 };
    my $content = do { local $/; <$fh> };
    close $fh;
    
    # Verificar se contém caracteres UTF-8 válidos
    eval {
        use Encode qw(decode);
        decode('utf8', $content, Encode::FB_CROAK);
    };
    
    return { valid => !$@ };
}

sub _validate_chapter_verses {
    my ($self, $book_name, $chapter_verses) = @_;
    my $errors = [];
    
    # Extrair capítulo e versículos
    my ($chapter) = $chapter_verses =~ /^(\d+)/;
    my ($verse_range) = $chapter_verses =~ /:(.+)$/;
    
    # Verificar se capítulo existe para o livro
    my $table_file = getcwd . "/tools/table-verses";
    if (-f $table_file) {
        open(my $fh, '<:utf8', $table_file) or return { valid => 1, errors => [] };
        my $found_chapter = 0;
        my $max_verses = 0;
        
        while (my $line = <$fh>) {
            chomp $line;
            if ($line =~ /^$book_name\s+$chapter\s+(\d+)/) {
                $found_chapter = 1;
                $max_verses = $1;
                last;
            }
        }
        close $fh;
        
        if (!$found_chapter) {
            push @$errors, {
                code => ERR_CHAPTER_INVALID,
                message => "Capítulo $chapter não encontrado para o livro $book_name",
                suggestion => "Verifique a tabela de referências em tools/table-verses"
            };
        } elsif ($verse_range) {
            # Validar range de versículos
            if ($verse_range =~ /^(\d+)-(\d+)$/) {
                my ($start, $end) = ($1, $2);
                if ($start > $end) {
                    push @$errors, {
                        code => ERR_INVALID_FORMAT,
                        message => "Range de versículos inválido: $start-$end",
                        suggestion => "O versículo inicial deve ser menor que o final"
                    };
                }
                if ($end > $max_verses) {
                    push @$errors, {
                        code => ERR_VERSE_MISMATCH,
                        message => "Versículo $end não existe no capítulo $chapter (máximo: $max_verses)",
                        suggestion => "Verifique o número de versículos no capítulo"
                    };
                }
            } elsif ($verse_range =~ /^(\d+)$/) {
                if ($1 > $max_verses) {
                    push @$errors, {
                        code => ERR_VERSE_MISMATCH,
                        message => "Solicitados $1 versículos, mas capítulo $chapter tem apenas $max_verses",
                        suggestion => "Ajuste o número de versículos ou use o formato correto"
                    };
                }
            }
        }
    }
    
    return { valid => @$errors == 0, errors => $errors };
}

sub _validate_theword_syntax {
    my ($self, $lines) = @_;
    my $errors = [];
    my $line_num = 0;
    
    for my $line (@$lines) {
        $line_num++;
        chomp $line;
        
        # Verificar tags de título malformadas
        if ($line =~ /<TS[12]>/ && $line !~ /<TS[12]>.*<Ts>/) {
            push @$errors, {
                code => ERR_SYNTAX_ERROR,
                message => "Tag de título malformada na linha $line_num: '$line'",
                suggestion => "Use o formato correto: <TS1>Título<Ts> ou <TS2>Subtítulo<Ts>"
            };
        }
        
        # Verificar referências de notas malformadas
        if ($line =~ /<RF q=(\d+)>/ && $line !~ /<RF q=\d+>.*<Rf>/) {
            push @$errors, {
                code => ERR_SYNTAX_ERROR,
                message => "Referência de nota malformada na linha $line_num: '$line'",
                suggestion => "Use o formato correto: <RF q=número>texto da nota<Rf>"
            };
        }
    }
    
    return $errors;
}

sub _check_orphan_notes {
    my ($self, $lines) = @_;
    my $errors = [];
    my $content = join('', @$lines);
    
    # Contar asteriscos não processados
    my $asterisk_count = () = $content =~ /\*/g;
    if ($asterisk_count > 0) {
        push @$errors, {
            code => ERR_SYNTAX_ERROR,
            message => "Encontrados $asterisk_count asterisco(s) não processado(s)",
            suggestion => "Verifique se todas as referências de notas foram marcadas com asterisco (*) e se há notas correspondentes"
        };
    }
    
    return $errors;
}

# Método para formatar e exibir erros
sub format_errors {
    my ($self, $errors) = @_;
    my $output = "\n";
    
    for my $error (@$errors) {
        $output .= "🔴 ERRO [" . $error->{code} . "]: " . $error->{message} . "\n";
        $output .= "💡 Sugestão: " . $error->{suggestion} . "\n\n";
    }
    
    return $output;
}

1;

__END__

=head1 NAME

TheWord::Validate - Sistema de validação para scripts TheWord

=head1 SYNOPSIS

    use TheWord::Validate;
    
    my $validator = TheWord::Validate->new(debug => 1);
    
    # Validar arquivos de entrada
    my $result = $validator->validate_input_files('input-verses.txt', 'input-notes.txt');
    
    # Validar parâmetros
    $result = $validator->validate_parameters('Lucas', '4:1-7');
    
    # Validar saída
    $result = $validator->validate_output('merged.txt', 7, 'Lucas');

=head1 DESCRIPTION

Este módulo fornece validação robusta para todos os aspectos do processamento
de textos bíblicos para o TheWord, incluindo validação de entrada, parâmetros
e saída.

=head1 METHODS

=head2 new(%args)

Cria uma nova instância do validador.

=head2 validate_input_files($verses_file, $notes_file)

Valida os arquivos de entrada de versículos e notas.

=head2 validate_parameters($book_name, $chapter_verses)

Valida os parâmetros fornecidos pelo usuário.

=head2 validate_output($merged_file, $expected_verses, $book_name)

Valida o arquivo de saída gerado.

=head2 format_errors($errors)

Formata uma lista de erros para exibição amigável.

=head1 AUTHOR

Instituto Reformado Santo Evangelho

=head1 COPYRIGHT

Copyright (c) 2025. Todos os direitos reservados.

=cut