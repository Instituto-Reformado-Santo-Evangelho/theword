#!/usr/bin/perl -w 

package TheWord::MergeLocal;

use v5.30;
use strict;
use warnings;
use Cwd;
use FindBin qw($RealBin);

# Importar sistemas de notas e codificação
use TheWord::BookNotes;
use TheWord::Encoding;
use TheWord::Convert;

# Variáveis globais 
my $book_notes = undef;
my $encoder = undef;

# Inicializar sistema de notas e codificação para livro específico
sub init_book_context {
    my ($Book_Name, $cap_verses) = @_;
    
    # Verifica se o nome do livro foi passado
    if (not defined $Book_Name) {
        die "Error: é preciso passar o nome do livro.\n";
    }
    # Verifica se o capítulo/versiculos foi passado como argumentos
    if (not defined $cap_verses) {
        die "Error: é preciso passar o capítulo de referência.\n";
    }
    
    # Criar instância do sistema de notas para este livro
    # NOVA ABORDAGEM: Cada livro começa do 1
    $book_notes = TheWord::BookNotes->new(
        book_name => $Book_Name,
        start_from => 1,  # SEMPRE começar do 1 para livros individuais
        debug => 0,
    );
    
    # Criar instância do codificador UTF-8 BOM
    $encoder = TheWord::Encoding->new(
        debug => 1,
        backup => 1,
    );
    
    print "📝 Sistema configurado para $Book_Name:\n";
    print "   ✅ Numeração local de notas (a partir de 1)\n";
    print "   ✅ Codificação UTF-8 com BOM obrigatória\n";
}

sub content {
    my ($Book_Name, $cap_verses, $verses, $notes) = @_;
    
    # Inicializar contexto se necessário
    if (!defined $book_notes || !defined $encoder) {
        init_book_context($Book_Name, $cap_verses);
    }
    
    # Processar versificação
    my $formatted_verses = versification($Book_Name, $cap_verses, $verses);
    
    # NOVA ABORDAGEM: Usar numeração local (1, 2, 3...)
    my $result = $book_notes->process_local_notes($formatted_verses, $notes);
    
    # Remover espaços no início das linhas dos versos
    $result =~ s/^\s+//gm;
    
    print "✅ Conteúdo processado com:\n";
    print "   📝 Numeração local de notas (começando do 1)\n";
    print "   🔤 Preparado para UTF-8 com BOM\n";
    print "ℹ️  IMPORTANTE: Este livro usa numeração local. O script de integração\n";
    print "   converterá para numeração global ao atualizar F35.nt\n";
    
    return $result;
}

# Salvar conteúdo com codificação UTF-8 BOM
sub save_with_utf8_bom {
    my ($file, $content) = @_;
    
    if (!defined $encoder) {
        $encoder = TheWord::Encoding->new(debug => 1, backup => 1);
    }
    
    # Salvar com BOM UTF-8
    $encoder->write_file_utf8_bom($file, $content);
    
    # Verificar se foi salvo corretamente
    if ($encoder->has_utf8_bom($file)) {
        print "✅ Arquivo salvo com UTF-8 BOM: $file\n";
        return 1;
    } else {
        die "❌ Falha ao salvar com UTF-8 BOM: $file\n";
    }
}

# Coloca referência de versos de acordo com os parâmetros recebidos
sub versification {
    my ($Book_Name, $cap_verses, $verses) = @_;
    
    # Recebe nome do livro e capítulo/verso, ex: Lucas 4:1-7
    my $book = TheWord::Convert::abrev($Book_Name);
    
    # Quebra $cap_verses e divide entre capítulo e verso
    my ($cap, $verses_range) = split /:/, $cap_verses;
    
    my @text_verses = split /\n/, $verses;
    my @cap_verses_ref = ();
    
    # Lógica de versificação (mantida igual)
    if (defined $verses_range) {
        if ($verses_range =~ /(\d+)-(\d+)/) {
            # Range de versículos (ex: 1-7)
            my ($start, $end) = ($1, $2);
            @cap_verses_ref = ($start..$end);
        } elsif ($verses_range =~ /^\d+$/) {
            # Número específico de versículos (ex: 30)
            @cap_verses_ref = (1..$verses_range);
        }
    } else {
        # Capítulo inteiro - obter do arquivo table-verses
        my $table_file = getcwd . "/tools/table-verses";
        if (-f $table_file) {
            open(my $fh, '<:utf8', $table_file);
            while (my $line = <$fh>) {
                chomp $line;
                if ($line =~ /^$Book_Name\s+$cap\s+(\d+)/) {
                    @cap_verses_ref = (1..$1);
                    last;
                }
            }
            close $fh;
        }
    }
    
    # Ignorar linhas vazias no início
    my $minIndex = 0;
    while ($minIndex < @text_verses && $text_verses[$minIndex] =~ /^\s*$/) {
        $minIndex++;
    }
    
    # Verificar correspondência
    if (($#text_verses - $minIndex) != ($#cap_verses_ref + 1)) {
        print "⚠️  O número de versículos passado como parâmetro \n";
        print "   não corresponde ao número de versículos do texto.\n";
        print "   Esperado: " . (@cap_verses_ref) . ", Encontrado: " . (@text_verses - $minIndex) . "\n";
        exit;
    }
    
    # Aplicar versificação
    my $result = "";
    for my $i ($minIndex..$#text_verses) {
        my $verse_num = $cap_verses_ref[$i - $minIndex];
        my $verse_text = $text_verses[$i];
        
        # Remover espaços extras
        $verse_text =~ s/^\s+//;
        $verse_text =~ s/\s+$//;
        
        # Adicionar referência do versículo
        $result .= "$cap:$verse_num $verse_text\n";
    }
    
    return $result;
}

1;

__END__

=head1 NAME

Merge - Sistema de merge com numeração local e UTF-8 BOM

=head1 SYNOPSIS

    use Merge;
    
    my $result = Merge::content("Lucas", "4:1-7", $verses, $notes);
    Merge::save_with_utf8_bom("Lc.nt", $result);

=head1 DESCRIPTION

Versão atualizada do sistema de merge que:
- Usa numeração local de notas para cada livro
- Garante codificação UTF-8 com BOM para TheWord
- Resolve conflitos de contribuidores simultâneos

=head1 FEATURES

✅ Numeração local por livro (1, 2, 3...)
✅ UTF-8 com BOM obrigatório
✅ Contribuidores independentes
✅ Integração controlada pelos mantenedores
✅ Compatibilidade total com TheWord

=head1 AUTHOR

Instituto Reformado Santo Evangelho

=head1 COPYRIGHT

Copyright (c) 2025. Todos os direitos reservados.

=cut