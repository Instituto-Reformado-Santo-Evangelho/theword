#!/usr/bin/perl -w 

use v5.30;
use strict;
use warnings;
use diagnostics;
use Cwd;
use FindBin::libs;
use Term::ANSIColor qw(:constants);
use Convert;


my $Book_Name = $ARGV[0];
# Verifica se o nome do livro foi passado
if (not defined $Book_Name) {
  print "Error: é preciso passar o nome do livro.\n";
  exit;
}
# Abrevia nome do livro
my $abrev_book = Convert::abrev($Book_Name);
# Define caminhos de arquivos
my $file_ref_verses = getcwd . "/perl/table-verses";
my $file_input_book = getcwd . "/modules/bible/f35/$abrev_book.nt";
my $file_main_f35 = getcwd . "/modules/bible/f35/F35.nt";

# Abre os arquivos para uso
open(my $input_ref_verses, $file_ref_verses) or die "Erro ao abrir arquivo: $!";
open(my $input_book, $file_input_book) or die "Erro ao abrir arquivo: $!";
open(my $input_main_f35, $file_main_f35) or die "Erro ao abrir arquivo: $!";

my $indexTotalVerses = 0;
my $endBookVerses = undef;
my $totalBookVerses = undef;
while(<$input_ref_verses>){
  my $ref = $_;
  if($ref =~ m/[A-Za-z0-9]\t+\d+\t+(\d+)/){
    $indexTotalVerses += $1;
    # Conta linhas até o ponto de inserção do novo livro
    if($ref =~ m/$Book_Name\t+\d+\t+(\d+)/){
      $totalBookVerses += $1;
      $endBookVerses = $indexTotalVerses;
      # Subtrai os versículos do primeiro capítulo
      if($ref =~ m/$Book_Name\t+1\t+(\d+)/){
        $endBookVerses -= $1-1;
      }
    }
  }
}

# Itera sobre as linhas do arquivo e injeta texto a partir do número de linhas da variável $indexBookVerses
my $startBookVerses = $endBookVerses - $totalBookVerses;
my $indexLine = 1;
my $indexLineBook = 0;
my @text_f35_modify = ();
my @text_book_modify = ();

#Transforma texto do livro (remove refs)
while(<$input_book>){
  chomp $_;
  # Remove refs
  $_ =~ s/(\s+)?\d+:\d+\s+//;
  push @text_book_modify, $_;
}

# Remove esse símbolo estranho da primeira linha do livro, se houver
$text_book_modify[0] =~ s/^(﻿)?//;

while(<$input_main_f35>){
  # Se o índice atual de linha for igual ao número da linha onde o livro começa e,
  # índice atual for menor ou igual ao número da linha onde o livro começa + total de linhas preenchidas do livro, então injetar texto do livro
  if($indexLine > $startBookVerses && $indexLine <= $startBookVerses + ($#text_book_modify + 1)){
    # Remove espaços do início de linhas do livro
    $text_book_modify[$indexLineBook] =~ s/^(\s+)?//;
    # Limpa texto da linha no arquivo principal, se houver
    $_ =~ s/(^.*$)?//;
    # Injeta nova linha de texto referente do livro
    $_ = "$text_book_modify[$indexLineBook]\n";
    # Coloca texto modificado no array, linha a linha
    push @text_f35_modify, $_;
    $indexLineBook++;
  }else{
    push @text_f35_modify, $_;
  }
  $indexLine++;
}

# Fecha orquivo principal de módulo F35.nt
close $input_main_f35 or die $!;

# Abre arquivo principal de módulo no modo gravação
open(my $output_main_f35, '>', $file_main_f35) or die "Erro ao abrir arquivo: $!";

# Substitui texto pelo texto alterado
print $output_main_f35 @text_f35_modify;

# Fecha arquivo
close $output_main_f35 or die $!;