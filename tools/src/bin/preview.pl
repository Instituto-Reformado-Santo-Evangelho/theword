#!/usr/bin/perl -w

# Script de preview avançado para TheWord
use v5.30;
use strict;
use warnings;
use FindBin qw($RealBin);
use Getopt::Long;

# Adicionar paths
use lib "$RealBin/../lib";
use Term::ANSIColor qw(:constants);

use TheWord::Preview;
use TheWord::Config;
use TheWord::Logger;

our $VERSION = '1.0.0';

# Opções da linha de comando
my %opts = (
    help => 0,
    file => undef,
    book => undef,
    chapter => undef,
    html => 0,
    interactive => 0,
    comparison => 0,
    quality => 0,
    output => undef,
    width => 80,
    before => undef,
    after => undef,
);

GetOptions(
    'help|h' => \$opts{help},
    'file|f=s' => \$opts{file},
    'book|b=s' => \$opts{book},
    'chapter|c=s' => \$opts{chapter},
    'html' => \$opts{html},
    'interactive|i' => \$opts{interactive},
    'comparison' => \$opts{comparison},
    'quality|q' => \$opts{quality},
    'output|o=s' => \$opts{output},
    'width|w=i' => \$opts{width},
    'before=s' => \$opts{before},
    'after=s' => \$opts{after},
) or die "Erro ao processar opções\n";

if ($opts{help}) {
    print_help();
    exit 0;
}

# Inicializar componentes
my $config = TheWord::Config->new();
my $logger = TheWord::Logger->new(console => 1, colors => 1);

# Determinar modo de formato baseado nas opções
my $format_mode = 'console';
$format_mode = 'html' if $opts{html};

my $preview = TheWord::Preview->new(
    width => $opts{width},
    format_mode => $format_mode,
    show_refs => 1,
    show_notes => 1,
);

print_header();

# Executar ação baseada nas opções
if ($opts{comparison} && $opts{before} && $opts{after}) {
    show_comparison();
} elsif ($opts{quality}) {
    analyze_quality();
} elsif ($opts{interactive}) {
    show_interactive_preview();
} elsif ($opts{html}) {
    generate_html_preview();
} else {
    show_console_preview();
}

sub show_console_preview {
    my $content = get_content();
    my $title = get_title();
    
    print $preview->preview_text($content, $title);
}

sub show_interactive_preview {
    my $content = get_content();
    my $title = get_title();
    
    $preview->interactive_preview($content, $title);
}

sub generate_html_preview {
    my $content = get_content();
    my $title = get_title();
    my $output_file = $opts{output} // "preview.html";
    
    my $file = $preview->generate_html_file($content, $output_file, $title);
    
    print BOLD GREEN "✅ Preview HTML gerado: $file\n" . RESET;
    print "🌐 Abra no navegador para visualização completa\n";
    
    # Tentar abrir automaticamente no navegador (Linux/macOS)
    if ($^O ne 'MSWin32') {
        system("which xdg-open >/dev/null 2>&1 && xdg-open '$file' &");
        system("which open >/dev/null 2>&1 && open '$file' &");
    }
}

sub show_comparison {
    my $before_content = read_file($opts{before});
    my $after_content = read_file($opts{after});
    
    my $title = "Comparação: " . ($opts{before} // "antes") . " vs " . ($opts{after} // "depois");
    
    $preview->preview_comparison($before_content, $after_content, $title);
}

sub analyze_quality {
    my $content = get_content();
    my $stats = $preview->analyze_quality($content);
    
    print BOLD CYAN "📊 Análise de Qualidade\n" . RESET;
    print "=" x 50 . "\n";
    
    # Estatísticas básicas
    print BOLD "📈 Estatísticas:\n" . RESET;
    printf "   Versículos: %d\n", $stats->{verses};
    printf "   Títulos: %d\n", $stats->{titles};
    printf "   Subtítulos: %d\n", $stats->{subtitles};
    printf "   Notas: %d\n", $stats->{notes};
    
    print "\n" . BOLD "🔍 Problemas Detectados:\n" . RESET;
    
    my $issues = 0;
    
    if ($stats->{orphan_asterisks} > 0) {
        print RED "   ❌ Asteriscos órfãos: $stats->{orphan_asterisks}\n" . RESET;
        $issues++;
    }
    
    if ($stats->{malformed_tags} > 0) {
        print RED "   ❌ Tags malformadas: $stats->{malformed_tags}\n" . RESET;
        $issues++;
    }
    
    if ($stats->{long_verses} > 0) {
        print YELLOW "   ⚠️  Versículos muito longos: $stats->{long_verses}\n" . RESET;
        $issues++;
    }
    
    if ($stats->{empty_notes} > 0) {
        print YELLOW "   ⚠️  Notas vazias: $stats->{empty_notes}\n" . RESET;
        $issues++;
    }
    
    if ($issues == 0) {
        print GREEN "   ✅ Nenhum problema detectado!\n" . RESET;
    }
    
    # Qualidade geral
    my $quality_score = calculate_quality_score($stats);
    print "\n" . BOLD "🎯 Pontuação de Qualidade: ";
    
    if ($quality_score >= 90) {
        print GREEN "$quality_score% - Excelente\n" . RESET;
    } elsif ($quality_score >= 75) {
        print YELLOW "$quality_score% - Bom\n" . RESET;
    } elsif ($quality_score >= 60) {
        print YELLOW "$quality_score% - Regular\n" . RESET;
    } else {
        print RED "$quality_score% - Precisa melhorar\n" . RESET;
    }
    
    print "=" x 50 . "\n";
}

sub get_content {
    my $file = $opts{file} // $config->get_file_path('merged') // 'merged.txt';
    
    if (!-f $file) {
        # Tentar outros arquivos padrão
        my @try_files = qw(edit-verses.txt input-verses.txt);
        for my $try_file (@try_files) {
            if (-f $try_file) {
                $file = $try_file;
                print YELLOW "⚠️  Usando arquivo alternativo: $file\n" . RESET;
                last;
            }
        }
    }
    
    if (!-f $file) {
        die RED "❌ Arquivo não encontrado: $file\n" . RESET .
            "Use --file para especificar um arquivo ou execute o processamento primeiro.\n";
    }
    
    return read_file($file);
}

sub read_file {
    my ($file) = @_;
    
    open(my $fh, '<:utf8', $file) or die "Erro ao ler arquivo $file: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    
    return $content;
}

sub get_title {
    my $title = "Preview TheWord";
    
    if ($opts{book}) {
        $title = "Preview: $opts{book}";
        $title .= " $opts{chapter}" if $opts{chapter};
    } elsif ($opts{file}) {
        my $filename = $opts{file};
        $filename =~ s/.*[\/\\]//;  # Extrair apenas o nome do arquivo
        $title = "Preview: $filename";
    }
    
    return $title;
}

sub calculate_quality_score {
    my ($stats) = @_;
    
    my $score = 100;
    
    # Penalidades
    $score -= $stats->{orphan_asterisks} * 5;     # -5 por asterisco órfão
    $score -= $stats->{malformed_tags} * 10;      # -10 por tag malformada
    $score -= $stats->{long_verses} * 2;          # -2 por versículo muito longo
    $score -= $stats->{empty_notes} * 3;          # -3 por nota vazia
    
    # Bônus por qualidade
    if ($stats->{verses} > 0 && $stats->{notes} > 0) {
        my $note_ratio = $stats->{notes} / $stats->{verses};
        $score += 5 if $note_ratio > 0.1;  # Bônus se há notas suficientes
    }
    
    return $score > 0 ? int($score) : 0;
}

sub print_header {
    print BOLD CYAN "\n";
    print "╔══════════════════════════════════════════════════════════════╗\n";
    print "║                    TheWord Preview Tool                     ║\n";
    print "║                      Versão $VERSION                           ║\n";
    print "╚══════════════════════════════════════════════════════════════╝\n";
    print RESET . "\n";
}

sub print_help {
    print <<'EOF';
Preview Tool - Visualização avançada de textos TheWord

USO: perl preview.pl [OPÇÕES]

OPÇÕES:
    --help, -h              Exibir esta ajuda
    --file, -f FILE         Arquivo para preview (padrão: merged.txt)
    --book, -b BOOK         Nome do livro (para título)
    --chapter, -c CHAP      Capítulo (para título)
    --html                  Gerar preview HTML
    --interactive, -i       Preview interativo com navegação
    --comparison            Comparar dois arquivos
    --quality, -q           Análise de qualidade
    --output, -o FILE       Arquivo de saída (para HTML)
    --width, -w NUM         Largura do console (padrão: 80)
    --before FILE           Arquivo "antes" (para comparação)
    --after FILE            Arquivo "depois" (para comparação)

EXEMPLOS:
    # Preview console simples
    perl preview.pl

    # Preview de arquivo específico
    perl preview.pl --file edit-verses.txt

    # Preview HTML
    perl preview.pl --html --book Lucas --chapter "4:1-7"

    # Preview interativo
    perl preview.pl --interactive --file merged.txt

    # Comparação de alterações
    perl preview.pl --comparison --before input-verses.txt --after edit-verses.txt

    # Análise de qualidade
    perl preview.pl --quality --file merged.txt

FORMATOS DE SAÍDA:
    console     - Preview colorido no terminal (padrão)
    html        - Arquivo HTML para navegador
    interactive - Navegação versículo por versículo

DESCRIÇÃO:
    Este script oferece várias formas de visualizar textos TheWord:
    
    🖥️  Console: Preview formatado e colorido no terminal
    🌐 HTML: Arquivo para visualização em navegador
    🎮 Interativo: Navegação por versículos com teclado
    📊 Qualidade: Análise detalhada de problemas
    🔄 Comparação: Lado a lado de alterações

    O preview HTML simula fielmente a aparência do TheWord,
    incluindo formatação de títulos, notas e referências.

EOF
}

# Carregar dependências necessárias
BEGIN {
    eval "use Term::ANSIColor qw(:constants)";
    
    # Fallback se módulos não estão disponíveis
    unless (defined &BOLD) {
        *BOLD = *RED = *GREEN = *BLUE = *CYAN = *YELLOW = *RESET = sub { "" };
    }
}

1;