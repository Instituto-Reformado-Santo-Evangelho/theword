#!/usr/bin/perl -w

use v5.30;
use strict;
use warnings;
use utf8;
use Encode qw(decode_utf8);
use Cwd;
use FindBin qw($RealBin);
use Term::ANSIColor qw(:constants);

# Adicionar caminhos
use lib "$RealBin/../src/lib";
use TheWord::Merge;

binmode STDOUT, ':utf8';

print BOLD CYAN "🧪 INICIANDO TESTES DE INTEGRIDADE
" . RESET;
print "=" x 40 . "
";

my $tests_passed = 0;
my $total_tests = 3;

# --- TESTE 1: Reconhecimento de Referência com Título ---
print "1. Teste de Regex de Versículo com Título... ";
my $line_with_title = "<TS1>Título<Ts> 1:1 Texto do verso";
if ($line_with_title =~ /(?:^|<Ts>)\s*(\d+:\d+)\s/) {
    my $ref = $1;
    if ($ref eq "1:1") {
        print GREEN "PASSED
" . RESET;
        $tests_passed++;
    } else {
        print RED "FAILED (Ref: $ref)
" . RESET;
    }
} else {
    print RED "FAILED (No match)
" . RESET;
}

# --- TESTE 2: Contagem de Versículos (Ignorar Vazio Final) ---
print "2. Teste de Contagem de Versículos (Trailing Newline)... ";
my $verses_text = "Linha 1
Linha 2

"; # Linha vazia no fim
my @text_verses = ();
while($verses_text =~ /(.*
?)/g){
    my $line = $1;
    push @text_verses, $line if $line =~ /\S/;
}
if (scalar(@text_verses) == 2) {
    print GREEN "PASSED
" . RESET;
    $tests_passed++;
} else {
    print RED "FAILED (Count: " . scalar(@text_verses) . ")
" . RESET;
}

# --- TESTE 3: Renumeração Global de Notas ---
print "3. Teste de Renumeração Global (integrate.pl logic)... ";
my $content = "1:1 Verso <RF q=99>Nota<Rf>
1:2 Verso <RF q=1>Nota<Rf>";
my $note_counter = 0;
$content =~ s/<RF q=\d+>/"<RF q=" . (++$note_counter) . ">"/ge;
if ($content =~ /q=1/ && $content =~ /q=2/ && $note_counter == 2) {
    print GREEN "PASSED
" . RESET;
    $tests_passed++;
} else {
    print RED "FAILED (Count: $note_counter)
" . RESET;
}

print "=" x 40 . "
";
if ($tests_passed == $total_tests) {
    print BOLD GREEN "✅ TODOS OS TESTES PASSARAM ($tests_passed/$total_tests)
" . RESET;
    exit 0;
} else {
    print BOLD RED "❌ ALGUNS TESTES FALHARAM ($tests_passed/$total_tests)
" . RESET;
    exit 1;
}
