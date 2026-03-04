#!/usr/bin/perl -w

package TheWord::Convert;

use v5.30;
use strict;
use warnings;
use utf8;

# Cria novo livro com nomenclatura abreviada
sub abrev {
    my $book_name = lc($_[0]);
    my $abrev = undef;

    if($book_name eq "mateus"){
       $abrev = "Mt";
    }elsif($book_name eq "marcos"){
       $abrev = "Mc";
    }elsif($book_name eq "lucas"){
       $abrev = "Lc";
    }
    elsif($book_name eq "joão"){
       $abrev = "Jo";
    }
    return $abrev;
}

sub abrev_in_name {
    my $abrev = lc($_[0]);
    my $book_name = undef;

    if($book_name eq "mt"){
       $book_name = "Mateus";
    }elsif($book_name eq "mc"){
       $book_name = "Marcos";
    }elsif($book_name eq "lc"){
       $book_name = "Lucas";
    }
    elsif($book_name eq "jo"){
       $book_name = "João";
    }
    return $book_name;
}

1;