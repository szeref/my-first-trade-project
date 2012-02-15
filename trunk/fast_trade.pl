#!/usr/bin/perl -w
#use strict;

sub read_file{
  open(DATA, $_[0]);
  my @lines = <DATA>;
  close(DATA);
  return @lines;
}

sub start{
  my @lines = read_file('EURUSD-Pro1.csv');
  our @BAR;

  my $i;
  my $len = $#lines;
  my @arr;
  
  foreach $i(0 .. $len){
    @arr = split(/,/, $lines[$i]); # 3 => high | 4 => low
    $BAR[$i][0] = $arr[3];
    $BAR[$i][1] = $arr[4];
    $BAR[$i][2] = $arr[0];
    # print $BAR[$i][1]."\n";
  }
  
  my $in_position;
  my $succ;
  my $fail;
  
  my $ENTER;
  my $TP;
  my $SL;
  my $INTERVAL;
  
  if (-e 'vars.txt') {
    my @vars = read_file('vars.txt');
    @arr = split(/;/, $vars[0]);
    $ENTER = $arr[0];
    $TP = $arr[1];
    $SL = $arr[2];
  }else{
    $ENTER = 0.00450;
    $TP = $ENTER + 0.00030;
    $SL = $ENTER - 0.00040;
    
    # $ENTER = 0.00560;
    # $TP = 0.00590;
    # $SL = 0.00510;
    # $INTERVAL = 10;
  } 
  
  my $lowest;
  my $highest;
  my $start_price;
  my $curr_interval;
  my $out = '';
  
  my $tp_top;
  my $sl_down;
  
  my $tmp;
  
  $succ_times = '';
  $fail_times = '';
  
  my $j = 0;
  my $k = 0;
  
  my $stdin = 0;

  while( $ENTER < 0.00621 ){
    $tp_top  = $ENTER + 0.00080;
    while( $TP < $tp_top ){
      $sl_down = $ENTER - 0.00090;
      while( $SL > $sl_down ){
            print_res('>> result', $out);
            print_res('> vars', $ENTER.';'.$TP.';'.$SL);
        foreach $INTERVAL(3..25){
            
          $in_position = 0;
          $succ = 0;
          $fail = 0;
          $last_pos = 0;
          foreach $i($INTERVAL .. $len){
            $h = $BAR[$i][0];
            $l = $BAR[$i][1];
            
            if($in_position == 1){
              if($start_price - $SL < $h){
                $fail++;
                $last_pos = $i;
                $in_position = 0;
                # $fail_times .= $BAR[$i][2]."\n";
              }elsif($start_price - $TP > $l){
                $succ++;
                $last_pos = $i;
                $in_position = 0;
                # $succ_times .= $BAR[$i][2]."\n";
              }
            }elsif($in_position == -1){
              if($start_price - $SL < $h){
                $fail++;
                $last_pos = $i;
                $in_position = 0;
                # $fail_times .= $BAR[$i][2]."\n";
              }elsif($start_price - $TP > $l){
                $succ++;
                $last_pos = $i;
                $in_position = 0;
                # $succ_times .= $BAR[$i][2]."\n";
              }
            }else{
              $tmp = $i - $last_pos;
              if($tmp < $INTERVAL){
                $curr_interval = $tmp;
              }else{
                $curr_interval = $INTERVAL;
              }
              
              $lowest = 999999;
              foreach $k(($i-$curr_interval) .. $i){
                if($lowest > $BAR[$k][1]){
                  $lowest = $BAR[$k][1];
                }
              }
              
              $tmp = $h-$lowest;
              if( $tmp > $ENTER){
                if( $tmp > $TP){
                  $succ++;
                  $last_pos = $i;
                  # $succ_times .= $BAR[$i][2]."\n";
                }else{
                  $in_position = 1;
                  $start_price = $lowest;
                }
                
              }else{
                $highest = 0;
                foreach $k(($i-$curr_interval) .. $i){
                  if($highest < $BAR[$k][0]){
                    $highest = $BAR[$k][0];
                  }
                }
              
                $tmp = $highest-$l;
                if($tmp > $TP){
                  if( $tmp > $TP){
                    $succ++;
                    $last_pos = $i;
                    # $succ_times .= $BAR[$i][2]."\n";
                  }else{
                    $in_position = -1;
                    $start_price = $highest;
                  }
                }
              }
            }
          }
          $out .= $ENTER."\t".$TP."\t".$SL."\t".$INTERVAL."\t".$fail."\t".$succ."\n";
          # print $j++.' '.$ENTER.' '.$TP.' '.$SL.' '.$INTERVAL.' '.$fail.' '.$succ.' | '.((($TP-$ENTER)*$succ)/(($ENTER-$SL)*$fail))."\n";
          print $j++.' '.$ENTER.' '.$TP.' '.$SL.' '.$INTERVAL.' '.$fail.' '.$succ."\n";
        }
        $SL = $SL - 0.00010;
      }
      $TP = $TP + 0.00010;
    }
    $ENTER = $ENTER + 0.00010;
  }
  
  # print $i.' '.$out;
  
print_res('>> result', $out);
  
  # print_res('succ', $succ_times);
  # print_res('fail', $fail_times);
}

sub print_res{
  open (MYFILE, $_[0].".txt");
  print MYFILE $_[1];
  close (MYFILE); 
}

sub getLowest{
  my $result = 999999;
  my $i;
  foreach $i($_[1]..$_[0]){
    if($result > $BAR[$i][1]){
      $result = $BAR[$i][1];
    }
  }
  return $result;
}

sub getHighest{
  my $result = 0;
  my $i;
  foreach $i($_[1]..$_[0]){
    if($result < $BAR[$i][0]){
      $result = $BAR[$i][0];
    }
  }
  return $result;
}

start();
