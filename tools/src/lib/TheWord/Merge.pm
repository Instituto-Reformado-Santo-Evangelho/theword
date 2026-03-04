#!/usr/bin/perl -w 

package TheWord::Merge;
use Cwd;
use utf8;
use TheWord::Convert;

# Variáveis globais (serão inicializadas quando necessário)
my $count = undef;

# Inicializar contexto do merge
sub init_context {
    my ($Book_Name, $cap_verses) = @_;
    
    my $book = TheWord::Convert::abrev($Book_Name);
    my $file_book_f35 = getcwd . "/modules/bible/f35/$book.nt";
    
    $count = 0; # Default se não encontrar nada

    if (-f $file_book_f35) {
        open(my $fh, '<:utf8', $file_book_f35) or die $!;
        my @lines = <$fh>;
        close $fh;

        # Determinar qual o primeiro versículo do range atual
        my ($target_cap, $target_ver);
        if ($cap_verses =~ /^(\d+):(\d+)/) {
            ($target_cap, $target_ver) = ($1, $2);
        } elsif ($cap_verses =~ /^(\d+)/) {
            ($target_cap, $target_ver) = ($1, 1);
        }

        # Procurar o último versículo ANTES do alvo para pegar a nota
        my $last_note_found = 0;
        foreach my $line (@lines) {
            if ($line =~ /^(\d+):(\d+)\s/) {
                my ($c, $v) = ($1, $2);
                # Se chegamos no versículo alvo, paramos de procurar
                last if ($c > $target_cap || ($c == $target_cap && $v >= $target_ver));
                
                # Capturar a última nota deste versículo
                while ($line =~ /<RF q=(\d+)>/g) {
                    $last_note_found = $1;
                }
            }
        }
        $count = $last_note_found;
    }
}

sub content {
    my ($Book_Name, $cap_verses, $verses, $notes) = @_;
    
    # Inicializar contexto se necessário
    if (!defined $count) {
        init_context($Book_Name, $cap_verses);
    }
    
    my $formatted_verses = versification($Book_Name, $cap_verses, $verses);
    
    # Processar notas
    my @note_lines = split(/\n/, $notes);
    foreach my $line (@note_lines){
        next unless $line =~ /\S/; # Pula linhas vazias
        
        $count++;
        $line =~ s/^\s+//;
        # Substitui o asterisco
        if ($formatted_verses =~ s/\*/<RF q=$count>$line<Rf>/) {
            # OK
        } else {
            warn "⚠️ Aviso: Nota encontrada mas nenhum asterisco (*) correspondente nos versículos: $line\n";
        }
    }
    
    # Remove espaços no início das linhas dos versos
    $formatted_verses =~ s/^\s+//gm;
    return $formatted_verses;
}

# Coloca referência de versos de acordo com os parâmetros recebidos
sub versification {
  my ($Book_name, $cap_verses, $verses_text) = @_;
  my $cap = $1 if $cap_verses =~ /(\d+):?/;
  my $verses = $1 if $cap_verses =~ /:(\d+-\d+)/;
  
  if( not defined $verses){
    open (my $file_verses, '<:utf8', getcwd . "/tools/table-verses");
    my @verses_ref = <$file_verses>;
    my $verses_ref = "@verses_ref";
    if (not $verses_ref =~ /$Book_name/){
      print "Livro não foi encontrado na tabela de referências\n";
      exit;
    }
    $verses = $1 if $verses_ref =~ /$Book_name\t+$cap\t+(\d+)/;
    close $file_verses or die "Erro ao fechar arquivo de referências: $!";
  }

  if(defined $verses){
    my $minIndex = undef;
    my $maxIndex = undef;
    if($verses =~ /(\d+)-(\d+)/){
      $minIndex = $1;
      $maxIndex = $2;
    }elsif($verses =~ /(\d+)/){
      $minIndex = 1;
      $maxIndex = $1;
    }

    my @text_verses = ();
    while($verses_text =~ /(.*\n?)/g){
      my $line = $1;
      # Adiciona apenas se a linha contiver algum caractere visível
      push @text_verses, $line if $line =~ /\S/;
    }

    if($minIndex > 1){
      for(my $i = 1; $i < $minIndex; $i++){
        unshift @text_verses, "\n";
      }
    }

    my @cap_verses_ref = ();
    my $current_verse = $minIndex;
    while($current_verse <= $maxIndex){
      push @cap_verses_ref, "$cap:$current_verse";
      if($text_verses[$current_verse-1] =~ m/(<TS.>.*<Ts>)/){
        $text_verses[$current_verse-1] =~ s/(<TS.>.*<Ts>)/$1 $cap:$current_verse /;
      }else{
        $text_verses[$current_verse-1] =~ s/^/$cap:$current_verse /;
      }
      $current_verse++;
    }

    if(scalar(@text_verses) != ($#cap_verses_ref+1)){
      print "O número de versículos (" . scalar(@text_verses) . ") não corresponde ao esperado (" . ($#cap_verses_ref+1) . ").\n\n";
      exit;
    }

    return join('', @text_verses);
  }
}

1;