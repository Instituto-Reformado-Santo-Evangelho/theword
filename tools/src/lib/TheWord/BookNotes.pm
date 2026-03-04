#!/usr/bin/perl -w

package TheWord::BookNotes;

use v5.30;
use strict;
use warnings;

our $VERSION = '1.0.0';

# Sistema de numeração independente por livro
# Cada livro individual usa numeração local (1, 2, 3...)
# O script de integração renumera para sequência global

# Construtor
sub new {
    my ($class, %args) = @_;
    
    my $self = {
        book_name => $args{book_name},
        start_from => $args{start_from} // 1,
        note_counter => $args{start_from} // 1,
        debug => $args{debug} // 0,
    };
    
    return bless $self, $class;
}

# Processar notas com numeração local (para livros individuais)
sub process_local_notes {
    my ($self, $verses, $notes) = @_;
    
    # Resetar contador para este livro
    $self->{note_counter} = $self->{start_from};
    
    my $formatted_verses = $verses;
    
    # Dividir notas e processar sequencialmente
    my @note_lines = split /\n\s*\n/, $notes;
    
    for my $note (@note_lines) {
        next unless $note =~ /\S/;
        
        # Limpar nota
        $note =~ s/^\s+//;
        $note =~ s/\s+$//;
        
        # Substituir primeiro asterisco pela nota numerada localmente
        if ($formatted_verses =~ s/\*/<RF q=$self->{note_counter}>$note<Rf>/) {
            $self->{note_counter}++;
        }
    }
    
    return $formatted_verses;
}

# Converter numeração local para global (usado pelo script de integração)
sub convert_to_global_numbering {
    my ($self, $content, $global_start_number) = @_;
    
    my $global_counter = $global_start_number;
    my $converted_content = $content;
    
    # Encontrar todas as referências locais e substituir por globais
    $converted_content =~ s/<RF q=(\d+)>/"<RF q=" . ($global_counter++) . ">"/ge;
    
    return {
        content => $converted_content,
        notes_used => $global_counter - $global_start_number,
        next_global_number => $global_counter,
    };
}

# Extrair metadados de notas de um livro
sub extract_note_metadata {
    my ($self, $content) = @_;
    
    my @note_refs = $content =~ /<RF q=(\d+)>/g;
    my @note_contents = $content =~ /<RF q=\d+>(.*?)<Rf>/gs;
    
    return {
        total_notes => scalar @note_refs,
        note_numbers => \@note_refs,
        note_contents => \@note_contents,
        first_note => @note_refs ? $note_refs[0] : undef,
        last_note => @note_refs ? $note_refs[-1] : undef,
    };
}

# Validar sequência de notas em um livro
sub validate_note_sequence {
    my ($self, $content) = @_;
    
    my @note_refs = $content =~ /<RF q=(\d+)>/g;
    my @errors = ();
    
    # Verificar se é sequencial começando do 1
    for my $i (0..$#note_refs) {
        my $expected = $i + 1;
        my $actual = $note_refs[$i];
        
        if ($actual != $expected) {
            push @errors, "Nota $actual deveria ser $expected (posição " . ($i + 1) . ")";
        }
    }
    
    # Verificar duplicatas
    my %seen;
    for my $ref (@note_refs) {
        if ($seen{$ref}++) {
            push @errors, "Nota $ref está duplicada";
        }
    }
    
    return {
        valid => @errors == 0,
        errors => \@errors,
        total_notes => scalar @note_refs,
    };
}

1;

__END__

=head1 NAME

TheWord::BookNotes - Sistema de numeração independente de notas por livro

=head1 SYNOPSIS

    use TheWord::BookNotes;
    
    # Para livros individuais - numeração local
    my $book_notes = TheWord::BookNotes->new(book_name => 'Lucas');
    my $content = $book_notes->process_local_notes($verses, $notes);
    
    # Para integração - converter para numeração global
    my $result = $book_notes->convert_to_global_numbering($content, 925);

=head1 DESCRIPTION

Este módulo resolve o problema de numeração de notas quando múltiplos 
contribuidores trabalham em livros diferentes simultaneamente.

PROBLEMA ANTERIOR:
- Numeração baseada no F35.nt atual
- Conflitos quando múltiplos contribuidores
- Dificuldade de integração

SOLUÇÃO ATUAL:
- Cada livro usa numeração local (1, 2, 3...)
- Script de integração renumera globalmente
- Contribuidores independentes

=head1 METHODS

=head2 new(%args)

Cria nova instância para processamento de notas.

=head2 process_local_notes($verses, $notes)

Processa notas usando numeração local (1, 2, 3...).

=head2 convert_to_global_numbering($content, $start_number)

Converte numeração local para global durante integração.

=head2 extract_note_metadata($content)

Extrai informações sobre notas de um conteúdo.

=head2 validate_note_sequence($content)

Valida se sequência de notas está correta.

=head1 AUTHOR

Instituto Reformado Santo Evangelho

=head1 COPYRIGHT

Copyright (c) 2025. Todos os direitos reservados.

=cut