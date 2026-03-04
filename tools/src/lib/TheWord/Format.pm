#!/usr/bin/perl -w

package TheWord::Format;

# Recebe o array de notas a ser formatadas;
sub notes {
  my @notes = ();
  my $notes = "@_";
  my $note = "";
  # Percorre cada linha de texto
  while($notes =~ /\n(.*)/g){
    # Add linha de conteúdo à variável $line
    my $line = $1;
    # Se a linha contiver apenas uma letra minúscula, então é a referência de nota
    if($line =~ /^\s*[a-z]\s*$/){
      # Add nota ao array de notas quando a referência da próxima nota é encontrada
      push @notes, "$note\n";
      # Esvazia $note
      $note = "";
    }else{
      # Concatena linhas até que a referência da próxima nota seja encontrada
      $note = $note . $line;
    }
  }
  # Add última nota
  push @notes, $note;
  # Remove espaço de início de linha e tranforma array em string
  $notes = trim(@notes);
  return $notes;
}

sub verses {
    my $verses = "@_";
    # Remove quebras de linhas
    $verses =~ s/\n//g;
    # Remove espaço duplo por um
    $verses =~ s/\s{2}/ /g;
    # Coloca cada versículo numa linha
    $verses =~ s/\d/\n/gm;
    # Remove linhas vazias
    $verses =~ s/^\s//gm;
    # Retorna buffer de versículos
    return $verses;
}

sub trim {
  my @notes = @_;
  foreach my $i (0 .. $#notes) {
    $notes[$i] =~ s/^\s*//;
  }
  return "@notes";
}

1;