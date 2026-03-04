#!/usr/bin/perl -w

# Script para validar e corrigir codificação UTF-8 BOM nos arquivos TheWord

use v5.30;
use strict;
use warnings;
use FindBin qw($RealBin);
use Getopt::Long;
use File::Find;

# Adicionar paths
use lib "$RealBin/../lib";
use TheWord::Encoding;

our $VERSION = '1.0.0';

# Opções
my %opts = (
    help => 0,
    check => 0,
    fix => 0,
    directory => 'modules/bible/f35',
    pattern => '*.nt',
    verbose => 0,
    backup => 1,
);

GetOptions(
    'help|h' => \$opts{help},
    'check|c' => \$opts{check},
    'fix|f' => \$opts{fix},
    'directory|d=s' => \$opts{directory},
    'pattern|p=s' => \$opts{pattern},
    'verbose|v' => \$opts{verbose},
    'backup|b!' => \$opts{backup},
) or die "Erro ao processar opções\n";

if ($opts{help}) {
    print_help();
    exit 0;
}

# Ao menos uma ação deve ser especificada
unless ($opts{check} || $opts{fix}) {
    $opts{check} = 1; # Default para check
}

# Inicializar codificador
my $encoder = TheWord::Encoding->new(
    debug => $opts{verbose},
    backup => $opts{backup},
);

print_header();

# Encontrar arquivos
my @files = find_nt_files($opts{directory}, $opts{pattern});

unless (@files) {
    print "❌ Nenhum arquivo .nt encontrado em $opts{directory}\n";
    exit 1;
}

print "📁 Diretório: $opts{directory}\n";
print "🔍 Padrão: $opts{pattern}\n";
print "📄 Arquivos encontrados: " . scalar(@files) . "\n\n";

# Verificar codificação
if ($opts{check}) {
    print "🔍 VERIFICANDO CODIFICAÇÃO UTF-8 BOM...\n\n";
    
    my $results = $encoder->validate_encoding(@files);
    print $encoder->encoding_report($results);
    
    # Contar problemas
    my $problems = grep { !$_->{valid} && $_->{exists} } @$results;
    
    if ($problems) {
        print "\n⚠️  $problems arquivo(s) precisam de correção.\n";
        
        unless ($opts{fix}) {
            print "💡 Use --fix para corrigir automaticamente.\n";
        }
    } else {
        print "\n✅ Todos os arquivos têm codificação UTF-8 BOM correta!\n";
    }
}

# Corrigir codificação
if ($opts{fix}) {
    print "\n🔧 CORRIGINDO CODIFICAÇÃO UTF-8 BOM...\n\n";
    
    my $result = $encoder->fix_theword_encoding(@files);
    
    if ($result->{success_count} > 0) {
        print "✅ Arquivos corrigidos com sucesso:\n";
        for my $file (@{$result->{fixed}}) {
            print "   📄 $file\n";
        }
    }
    
    if ($result->{error_count} > 0) {
        print "\n❌ Erros encontrados:\n";
        for my $error (@{$result->{errors}}) {
            print "   📄 $error->{file}: $error->{error}\n";
        }
    }
    
    print "\n📊 Resumo:\n";
    print "   ✅ Sucessos: $result->{success_count}\n";
    print "   ❌ Erros: $result->{error_count}\n";
    print "   📄 Total: $result->{total_processed}\n";
}

# Verificação final se foi feita correção
if ($opts{fix}) {
    print "\n🔍 VERIFICAÇÃO FINAL...\n";
    
    my $final_results = $encoder->validate_encoding(@files);
    my $remaining_problems = grep { !$_->{valid} && $_->{exists} } @$final_results;
    
    if ($remaining_problems == 0) {
        print "🎉 SUCESSO: Todos os arquivos agora têm UTF-8 BOM correto!\n";
    } else {
        print "⚠️  Ainda há $remaining_problems problema(s) de codificação.\n";
    }
}

print "\n" . "=" x 60 . "\n";
print "ℹ️  IMPORTANTE: TheWord requer UTF-8 com BOM para exibir\n";
print "   acentos e caracteres especiais corretamente.\n";
print "   BOM necessário: EF BB BF (início do arquivo)\n";

sub find_nt_files {
    my ($directory, $pattern) = @_;
    
    my @found_files = ();
    
    # Converter pattern shell para regex
    $pattern =~ s/\*/\.\*/g;
    $pattern =~ s/\?/\./g;
    
    if (-d $directory) {
        find(sub {
            if (-f $_ && $_ =~ /$pattern$/i) {
                push @found_files, $File::Find::name;
            }
        }, $directory);
    } elsif (-f $directory && $directory =~ /$pattern$/i) {
        push @found_files, $directory;
    }
    
    return sort @found_files;
}

sub print_header {
    print <<'EOF';

╔══════════════════════════════════════════════════════════════╗
║           VALIDADOR DE CODIFICAÇÃO UTF-8 BOM                ║
║                  Para Arquivos TheWord                      ║
╚══════════════════════════════════════════════════════════════╝

🎯 Este script garante que arquivos .nt tenham UTF-8 com BOM
   para exibição correta de acentos no software TheWord.

EOF
}

sub print_help {
    print <<'EOF';
Validador de Codificação UTF-8 BOM para TheWord

USO: perl check-encoding.pl [OPÇÕES]

OPÇÕES:
    --help, -h              Exibir esta ajuda
    --check, -c             Verificar codificação (padrão)
    --fix, -f               Corrigir problemas encontrados
    --directory, -d DIR     Diretório a verificar (padrão: modules/bible/f35)
    --pattern, -p PATTERN   Padrão de arquivos (padrão: *.nt)
    --verbose, -v           Saída detalhada
    --backup, -b            Fazer backup antes de corrigir (padrão: sim)
    --no-backup             Não fazer backup

EXEMPLOS:
    # Verificar arquivos padrão
    perl check-encoding.pl --check

    # Corrigir problemas encontrados
    perl check-encoding.pl --fix

    # Verificar diretório específico
    perl check-encoding.pl --check --directory=modules/bible/f35

    # Corrigir com saída detalhada
    perl check-encoding.pl --fix --verbose

    # Verificar arquivo específico
    perl check-encoding.pl --check --directory=modules/bible/f35/Lc.nt

IMPORTANTE:
    TheWord requer UTF-8 com BOM (EF BB BF) para:
    ✅ Exibição correta de acentos (á, ã, ç, ê, etc.)
    ✅ Caracteres especiais portugueses
    ✅ Compatibilidade com todas as versões
    ✅ Detecção automática de codificação

CODIFICAÇÃO NECESSÁRIA:
    - Formato: UTF-8 com BOM
    - BOM: EF BB BF (primeiros 3 bytes)
    - Sem BOM = acentos podem aparecer incorretos

ESTRUTURA DE ARQUIVO CORRETO:
    EF BB BF [conteúdo UTF-8]
    ↑ BOM   ↑ texto com acentos

EOF
}

1;