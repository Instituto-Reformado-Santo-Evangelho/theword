#!/usr/bin/perl -w

use v5.30;
use strict;
use warnings;
use utf8;
use Encode qw(decode_utf8);
use Cwd;
use FindBin qw($RealBin);
use Term::ANSIColor qw(:constants);
use File::Copy qw(copy);

# Adicionar caminhos
use lib "$RealBin/../lib";
use TheWord::Config;
use TheWord::Convert;

binmode STDOUT, ':utf8';
binmode STDIN,  ':utf8';

my $config = TheWord::Config->new();

sub main {
    my ($book_name) = map { decode_utf8($_) } @ARGV;

    if (!$book_name) {
        print "USO: perl integrate.pl [LIVRO]\n";
        exit 1;
    }

    my $merged_file = $config->get_file_path('merged');
    my $abrev = TheWord::Convert::abrev($book_name);
    my $book_path = $config->get_file_path('modules_dir') . "/$abrev.nt";

    if (!-f $merged_file) { die "❌ Erro: merged.txt não encontrado em $merged_file\n"; }

    print BOLD YELLOW "🔄 Integrando em $abrev.nt...\n" . RESET;

    # 1. Carregar novos versos do merged (Hash para acesso rápido)
    open(my $mh, '<:utf8', $merged_file) or die $!;
    my %new_verses;
    while(my $line = <$mh>) {
        if ($line =~ /(?:^|<Ts>)\s*(\d+:\d+)\s/) { 
            $new_verses{$1} = $line; 
        }
    }
    close $mh;

    # 2. Carregar livro atual (se existir)
    my %final_content;
    if (-f $book_path) {
        open(my $bh, '<:utf8', $book_path) or die $!;
        while (my $line = <$bh>) {
            if ($line =~ /(?:^|<Ts>)\s*(\d+:\d+)\s/) {
                $final_content{$1} = $line;
            }
        }
        close $bh;
    }

    # 3. Sobrepor conteúdo (Surgical Replace / Add)
    foreach my $ref (keys %new_verses) {
        $final_content{$ref} = $new_verses{$ref};
    }

    # 4. Organizar conteúdo por ordem de capítulo:versículo
    my @sorted_refs = sort {
        my ($a_cap, $a_ver) = split(/:/, $a);
        my ($b_cap, $b_ver) = split(/:/, $b);
        $a_cap <=> $b_cap || $a_ver <=> $b_ver
    } keys %final_content;

    my @updated_lines;
    foreach my $ref (@sorted_refs) {
        push @updated_lines, $final_content{$ref};
    }

    if (!@updated_lines) {
        die "❌ Erro: Nenhum conteúdo válido para integrar.\n";
    }

    # 5. Renumeração Global de todas as notas do livro (Integridade total)
    my $note_counter = 0;
    foreach my $line (@updated_lines) {
        # Substitui q=NUMERO por q=SEQUENCIA
        $line =~ s/<RF q=\d+>/"<RF q=" . (++$note_counter) . ">"/ge;
    }

    # 6. Salvar o arquivo (Garantir que diretório existe)
    use File::Basename;
    my $dir = dirname($book_path);
    if (!-d $dir) {
        require File::Path;
        File::Path::make_path($dir);
    }

    open(my $out, '>:utf8', $book_path) or die "Erro ao salvar em $book_path: $!";
    print $out @updated_lines;
    close $out;

    print BOLD GREEN "✅ Sucesso! $abrev.nt atualizado e renumerado.\n" . RESET;
    print "   Versículos no livro: " . scalar(@updated_lines) . "\n";
    print "   Total de notas: $note_counter\n";
}

main();
