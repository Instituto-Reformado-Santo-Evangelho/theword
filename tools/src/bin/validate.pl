#!/usr/bin/perl -w

# Script de validação independente
use v5.30;
use strict;
use warnings;
use FindBin qw($RealBin);
use Getopt::Long;

# Adicionar paths
use lib "$RealBin/../lib";

use TheWord::Validate;
use TheWord::Logger;
use TheWord::Config;

our $VERSION = '1.0.0';

# Opções da linha de comando
my %opts = (
    help => 0,
    file => undef,
    book => undef,
    chapter => undef,
    debug => 0,
);

GetOptions(
    'help|h' => \$opts{help},
    'file|f=s' => \$opts{file},
    'book|b=s' => \$opts{book},
    'chapter|c=s' => \$opts{chapter},
    'debug|d' => \$opts{debug},
) or die "Erro ao processar opções da linha de comando\n";

if ($opts{help}) {
    print_help();
    exit 0;
}

# Inicializar componentes
my $config = TheWord::Config->new();
my $logger = TheWord::Logger->new(
    level => $opts{debug} ? TheWord::Logger::LEVEL_DEBUG : TheWord::Logger::LEVEL_INFO,
    console => 1,
    colors => 1,
);
my $validator = TheWord::Validate->new(debug => $opts{debug});

print "🔍 Validador TheWord v$VERSION\n";
print "=" x 40 . "\n";

# Validar arquivo específico
if ($opts{file}) {
    validate_file($opts{file}, $opts{book});
}
# Validar parâmetros
elsif ($opts{book} && $opts{chapter}) {
    validate_parameters($opts{book}, $opts{chapter});
}
# Validar arquivos padrão
else {
    validate_default_files();
}

sub validate_file {
    my ($file, $book) = @_;
    
    print "📄 Validando arquivo: $file\n";
    
    if (!-f $file) {
        print "❌ Arquivo não encontrado: $file\n";
        exit 1;
    }
    
    my $result = $validator->validate_output($file, undef, $book);
    
    if ($result->{valid}) {
        print "✅ Arquivo válido!\n";
    } else {
        print "❌ Problemas encontrados:\n";
        print $validator->format_errors($result->{errors});
        exit 1;
    }
}

sub validate_parameters {
    my ($book, $chapter) = @_;
    
    print "📋 Validando parâmetros: $book $chapter\n";
    
    my $result = $validator->validate_parameters($book, $chapter);
    
    if ($result->{valid}) {
        print "✅ Parâmetros válidos!\n";
    } else {
        print "❌ Parâmetros inválidos:\n";
        print $validator->format_errors($result->{errors});
        exit 1;
    }
}

sub validate_default_files {
    print "📁 Validando arquivos padrão...\n";
    
    my $verses_file = $config->get_file_path('input_verses');
    my $notes_file = $config->get_file_path('input_notes');
    
    my $result = $validator->validate_input_files($verses_file, $notes_file);
    
    if ($result->{valid}) {
        print "✅ Arquivos de entrada válidos!\n";
    } else {
        print "❌ Problemas nos arquivos de entrada:\n";
        print $validator->format_errors($result->{errors});
        exit 1;
    }
}

sub print_help {
    print <<'EOF';
Validador TheWord - Ferramenta de validação independente

USO: perl validate.pl [OPÇÕES]

OPÇÕES:
    --help, -h           Exibir esta ajuda
    --file, -f FILE      Validar arquivo específico
    --book, -b BOOK      Nome do livro (usar com --chapter)
    --chapter, -c CHAP   Capítulo/versículos (usar com --book)
    --debug, -d          Modo debug

EXEMPLOS:
    perl validate.pl                        # Validar arquivos padrão
    perl validate.pl --file merged.txt      # Validar arquivo específico
    perl validate.pl --book Lucas --chapter 4:1-7  # Validar parâmetros
    perl validate.pl --file merged.txt --book Lucas # Validar com contexto

DESCRIÇÃO:
    Este script permite validar arquivos e parâmetros independentemente
    do processamento principal. Útil para debug e verificação de qualidade.

EOF
}

1;