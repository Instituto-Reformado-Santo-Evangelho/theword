#!/usr/bin/perl -w

package TheWord::Preview;

use v5.30;
use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use FindBin qw($RealBin);
use lib "$RealBin";
use TheWord::Logger;
use TheWord::Config;

our $VERSION = '1.0.0';

# Construtor
sub new {
    my ($class, %args) = @_;
    
    my $self = {
        config => TheWord::Config->new(),
        logger => TheWord::Logger->new(),
        width => $args{width} // 80,
        show_refs => $args{show_refs} // 1,
        show_notes => $args{show_notes} // 1,
        color_mode => $args{color_mode} // 'auto',
        format_mode => $args{format_mode} // 'console', # console, html, text
    };
    
    return bless $self, $class;
}

# Preview principal do texto formatado
sub preview_text {
    my ($self, $content, $title) = @_;
    
    $title //= "Preview do Texto TheWord";
    
    if ($self->{format_mode} eq 'html') {
        return $self->_generate_html_preview($content, $title);
    } elsif ($self->{format_mode} eq 'text') {
        return $self->_generate_text_preview($content, $title);
    } else {
        return $self->_generate_console_preview($content, $title);
    }
}

# Preview comparativo (antes/depois)
sub preview_comparison {
    my ($self, $before, $after, $title) = @_;
    
    $title //= "Comparação de Alterações";
    
    print BOLD CYAN "\n📊 $title\n" . RESET;
    print "=" x $self->{width} . "\n";
    
    # Dividir em colunas
    my $col_width = int(($self->{width} - 5) / 2);
    
    print BOLD "ANTES" . " " x ($col_width - 5) . " │ " . "DEPOIS\n" . RESET;
    print "-" x $col_width . "─┼─" . "-" x $col_width . "\n";
    
    my @before_lines = split /\n/, $before;
    my @after_lines = split /\n/, $after;
    my $max_lines = scalar(@before_lines) > scalar(@after_lines) ? scalar(@before_lines) : scalar(@after_lines);
    
    for my $i (0..$max_lines-1) {
        my $left = $before_lines[$i] // "";
        my $right = $after_lines[$i] // "";
        
        # Truncar se necessário
        $left = substr($left, 0, $col_width-2) . ".." if length($left) > $col_width;
        $right = substr($right, 0, $col_width-2) . ".." if length($right) > $col_width;
        
        # Detectar mudanças
        my $color = "";
        my $reset = "";
        if ($left ne $right) {
            $color = YELLOW;
            $reset = RESET;
        }
        
        printf "%s%-${col_width}s%s │ %s%-${col_width}s%s\n", 
               $color, $left, $reset, $color, $right, $reset;
    }
    
    print "=" x $self->{width} . "\n";
}

# Preview estilo navegador (HTML)
sub generate_html_file {
    my ($self, $content, $output_file, $title) = @_;
    
    $title //= "Preview TheWord";
    $output_file //= "preview.html";
    
    my $html = $self->_generate_html_preview($content, $title);
    
    open(my $fh, '>:utf8', $output_file) or die "Erro ao criar arquivo HTML: $!";
    print $fh $html;
    close $fh;
    
    $self->{logger}->info("Preview HTML gerado: $output_file");
    return $output_file;
}

# Preview interativo com navegação
sub interactive_preview {
    my ($self, $content, $title) = @_;
    
    my @verses = $self->_parse_verses($content);
    my $current = 0;
    my $total = scalar @verses;
    
    while (1) {
        system('clear') if $^O ne 'MSWin32';
        
        print BOLD CYAN "\n📖 $title - Navegação Interativa\n" . RESET;
        print "=" x $self->{width} . "\n";
        print BOLD "Versículo " . ($current + 1) . " de $total\n" . RESET;
        print "-" x $self->{width} . "\n";
        
        # Mostrar versículo atual
        $self->_display_verse($verses[$current]);
        
        print "\n" . "-" x $self->{width} . "\n";
        print BOLD "Navegação: " . RESET;
        print "[←] Anterior  [→] Próximo  [G] Ir para  [Q] Sair\n";
        print "Escolha: ";
        
        my $input = <STDIN>;
        chomp $input;
        $input = lc($input);
        
        if ($input eq 'q' || $input eq 'quit' || $input eq 'sair') {
            last;
        } elsif ($input eq 'p' || $input eq 'prev' || $input eq '←') {
            $current-- if $current > 0;
        } elsif ($input eq 'n' || $input eq 'next' || $input eq '→' || $input eq '') {
            $current++ if $current < $total - 1;
        } elsif ($input eq 'g' || $input eq 'goto') {
            print "Ir para versículo (1-$total): ";
            my $goto = <STDIN>;
            chomp $goto;
            if ($goto =~ /^\d+$/ && $goto >= 1 && $goto <= $total) {
                $current = $goto - 1;
            }
        }
    }
}

# Métodos privados

sub _generate_console_preview {
    my ($self, $content, $title) = @_;
    
    my $output = "";
    
    # Cabeçalho
    $output .= BOLD CYAN "\n📖 $title\n" . RESET;
    $output .= "=" x $self->{width} . "\n";
    
    # Processar conteúdo linha por linha
    my @lines = split /\n/, $content;
    my $verse_num = 1;
    
    for my $line (@lines) {
        $output .= $self->_format_console_line($line, $verse_num);
        $verse_num++ if $line =~ /^\d+:\d+/;
    }
    
    $output .= "=" x $self->{width} . "\n\n";
    
    return $output;
}

sub _format_console_line {
    my ($self, $line, $verse_num) = @_;
    
    my $formatted = "";
    
    # Títulos principais
    if ($line =~ s/<TS1>(.*?)<Ts>/$1/g) {
        $formatted .= "\n" . BOLD BLUE "▋ $1\n" . RESET;
        $line =~ s/\Q$1\E//g;
    }
    
    # Subtítulos
    if ($line =~ s/<TS2>(.*?)<Ts>/$1/g) {
        $formatted .= "\n" . BOLD GREEN "  ▋ $1\n" . RESET;
        $line =~ s/\Q$1\E//g;
    }
    
    # Referência do versículo
    if ($line =~ s/^(\d+:\d+)\s*//) {
        my $ref = $1;
        $formatted .= BOLD YELLOW "$ref" . RESET . " ";
    }
    
    # Texto com formatação
    $line =~ s/<FU>(.*?)<Fu>/\033[4m$1\033[0m/g;  # Sublinhado
    $line =~ s/<I>(.*?)<i>/\033[3m$1\033[0m/g;    # Itálico
    $line =~ s/<B>(.*?)<b>/\033[1m$1\033[0m/g;    # Negrito
    
    # Notas de rodapé
    if ($self->{show_notes}) {
        $line =~ s/<RF q=(\d+)>(.*?)<Rf>/\033[36m[$1]\033[0m/g;
    } else {
        $line =~ s/<RF q=(\d+)>(.*?)<Rf>/\033[36m[$1]\033[0m/g;
    }
    
    # Quebrar linhas longas
    if (length($line) > $self->{width} - 10) {
        $line = $self->_wrap_text($line, $self->{width} - 10);
    }
    
    $formatted .= "$line\n" if $line =~ /\S/;
    
    return $formatted;
}

sub _generate_html_preview {
    my ($self, $content, $title) = @_;
    
    my $html = <<EOF;
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        body {
            font-family: 'Times New Roman', serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f9f9f9;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .title1 {
            color: #2c3e50;
            font-size: 1.4em;
            font-weight: bold;
            margin: 20px 0 10px 0;
            border-left: 4px solid #3498db;
            padding-left: 10px;
        }
        .title2 {
            color: #27ae60;
            font-size: 1.2em;
            font-weight: bold;
            margin: 15px 0 8px 20px;
            border-left: 3px solid #27ae60;
            padding-left: 8px;
        }
        .verse {
            margin: 8px 0;
            text-align: justify;
        }
        .verse-ref {
            color: #e74c3c;
            font-weight: bold;
            margin-right: 8px;
        }
        .note-ref {
            color: #9b59b6;
            font-size: 0.85em;
            vertical-align: super;
            cursor: pointer;
            text-decoration: none;
        }
        .note-ref:hover {
            background-color: #f39c12;
            color: white;
            padding: 1px 3px;
            border-radius: 3px;
        }
        .underline {
            text-decoration: underline;
        }
        .italic {
            font-style: italic;
        }
        .bold {
            font-weight: bold;
        }
        .preview-header {
            text-align: center;
            color: #34495e;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .verse-count {
            position: fixed;
            top: 10px;
            right: 10px;
            background: #3498db;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.8em;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="preview-header">
            <h1>$title</h1>
            <p>Preview simulando visualização TheWord</p>
        </div>
EOF

    # Processar conteúdo
    my @lines = split /\n/, $content;
    my $verse_count = 0;
    
    for my $line (@lines) {
        next unless $line =~ /\S/;
        
        # Contar versículos
        $verse_count++ if $line =~ /^\d+:\d+/;
        
        # Títulos principais
        $line =~ s/<TS1>(.*?)<Ts>/<div class="title1">$1<\/div>/g;
        
        # Subtítulos
        $line =~ s/<TS2>(.*?)<Ts>/<div class="title2">$1<\/div>/g;
        
        # Formatação de texto
        $line =~ s/<FU>(.*?)<Fu>/<span class="underline">$1<\/span>/g;
        $line =~ s/<I>(.*?)<i>/<span class="italic">$1<\/span>/g;
        $line =~ s/<B>(.*?)<b>/<span class="bold">$1<\/span>/g;
        
        # Referências de versículos
        $line =~ s/^(\d+:\d+)\s*/<span class="verse-ref">$1<\/span>/;
        
        # Notas de rodapé
        $line =~ s/<RF q=(\d+)>(.*?)<Rf>/<a href="#" class="note-ref" title="$2">[$1]<\/a>/g;
        
        # Envolver versículos
        if ($line =~ /verse-ref/) {
            $html .= "        <div class=\"verse\">$line</div>\n";
        } else {
            $html .= "        $line\n";
        }
    }
    
    $html .= <<EOF;
        <div class="verse-count">$verse_count versículos</div>
    </div>
    
    <script>
        // Funcionalidade para notas
        document.querySelectorAll('.note-ref').forEach(function(note) {
            note.addEventListener('click', function(e) {
                e.preventDefault();
                alert('Nota: ' + this.getAttribute('title'));
            });
        });
        
        // Atalhos de teclado
        document.addEventListener('keydown', function(e) {
            if (e.key === 'F5') {
                e.preventDefault();
                location.reload();
            }
        });
    </script>
</body>
</html>
EOF

    return $html;
}

sub _generate_text_preview {
    my ($self, $content, $title) = @_;
    
    my $output = "";
    $output .= "=" x $self->{width} . "\n";
    $output .= " " x int(($self->{width} - length($title)) / 2) . "$title\n";
    $output .= "=" x $self->{width} . "\n\n";
    
    # Limpar tags para texto puro
    my $clean_content = $content;
    $clean_content =~ s/<TS1>(.*?)<Ts>/\n▋ $1\n/g;
    $clean_content =~ s/<TS2>(.*?)<Ts>/\n  ▋ $1\n/g;
    $clean_content =~ s/<FU>(.*?)<Fu>/_$1_/g;
    $clean_content =~ s/<I>(.*?)<i>/*$1*/g;
    $clean_content =~ s/<B>(.*?)<b>/**$1**/g;
    $clean_content =~ s/<RF q=(\d+)>(.*?)<Rf>/[$1]/g;
    
    $output .= $clean_content;
    $output .= "\n" . "=" x $self->{width} . "\n";
    
    return $output;
}

sub _parse_verses {
    my ($self, $content) = @_;
    
    my @verses = ();
    my @lines = split /\n/, $content;
    
    for my $line (@lines) {
        next unless $line =~ /\S/;
        if ($line =~ /^\d+:\d+/ || $line =~ /<TS[12]>/) {
            push @verses, $line;
        }
    }
    
    return @verses;
}

sub _display_verse {
    my ($self, $verse) = @_;
    
    # Formatação especial para navegação interativa
    my $formatted = $self->_format_console_line($verse, 0);
    
    # Adicionar informações extras
    if ($verse =~ /<RF q=(\d+)>/) {
        my @notes = $verse =~ /<RF q=(\d+)>(.*?)<Rf>/g;
        if (@notes) {
            print $formatted;
            print "\n" . BOLD CYAN "📝 Notas:\n" . RESET;
            for (my $i = 0; $i < @notes; $i += 2) {
                my $num = $notes[$i];
                my $text = $notes[$i + 1];
                print YELLOW "[$num]" . RESET . " " . substr($text, 0, 60) . "...\n";
            }
        }
    } else {
        print $formatted;
    }
}

sub _wrap_text {
    my ($self, $text, $width) = @_;
    
    my @words = split /\s+/, $text;
    my @lines = ();
    my $current_line = "";
    
    for my $word (@words) {
        if (length($current_line . " " . $word) <= $width) {
            $current_line .= ($current_line ? " " : "") . $word;
        } else {
            push @lines, $current_line if $current_line;
            $current_line = $word;
        }
    }
    
    push @lines, $current_line if $current_line;
    return join("\n" . " " x 8, @lines);
}

# Análise de qualidade do texto
sub analyze_quality {
    my ($self, $content) = @_;
    
    my %stats = (
        verses => 0,
        titles => 0,
        subtitles => 0,
        notes => 0,
        orphan_asterisks => 0,
        malformed_tags => 0,
        long_verses => 0,
        empty_notes => 0,
    );
    
    my @lines = split /\n/, $content;
    
    for my $line (@lines) {
        # Contar elementos
        $stats{verses}++ if $line =~ /^\d+:\d+/;
        $stats{titles}++ while $line =~ /<TS1>.*?<Ts>/g;
        $stats{subtitles}++ while $line =~ /<TS2>.*?<Ts>/g;
        $stats{notes}++ while $line =~ /<RF q=\d+>.*?<Rf>/g;
        
        # Detectar problemas
        $stats{orphan_asterisks}++ while $line =~ /\*/g;
        $stats{malformed_tags}++ if $line =~ /<TS[12]>(?!.*<Ts>)/ || $line =~ /<RF q=\d+>(?!.*<Rf>)/;
        $stats{long_verses}++ if length($line) > 200;
        $stats{empty_notes}++ while $line =~ /<RF q=\d+><Rf>/g;
    }
    
    return \%stats;
}

1;

__END__

=head1 NAME

TheWord::Preview - Sistema de preview avançado para textos TheWord

=head1 SYNOPSIS

    use TheWord::Preview;
    
    my $preview = TheWord::Preview->new(width => 80, format_mode => 'console');
    
    # Preview console
    print $preview->preview_text($content, "Lucas 4:1-7");
    
    # Preview HTML
    $preview->generate_html_file($content, "preview.html", "Preview Lucas");
    
    # Preview interativo
    $preview->interactive_preview($content, "Navegação Lucas");
    
    # Comparação
    $preview->preview_comparison($before, $after, "Alterações");

=head1 DESCRIPTION

Sistema avançado de preview que simula a visualização do TheWord em diferentes
formatos: console colorido, HTML navegável e navegação interativa.

=head1 METHODS

=head2 new(%args)

Cria nova instância do sistema de preview.

=head2 preview_text($content, $title)

Gera preview formatado do conteúdo.

=head2 preview_comparison($before, $after, $title)

Mostra comparação lado a lado de alterações.

=head2 generate_html_file($content, $output_file, $title)

Gera arquivo HTML para visualização em navegador.

=head2 interactive_preview($content, $title)

Preview interativo com navegação por versículos.

=head2 analyze_quality($content)

Analisa qualidade e detecta problemas no texto.

=head1 AUTHOR

Instituto Reformado Santo Evangelho

=head1 COPYRIGHT

Copyright (c) 2025. Todos os direitos reservados.

=cut