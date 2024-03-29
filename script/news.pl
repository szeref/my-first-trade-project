#!/usr/bin/perl

# BEGIN {
	# Win32::SetChildShowWindow(0) if defined &Win32::SetChildShowWindow
# };

# use YAML::XS;
# use Data::Dumper;

use LWP::UserAgent;
use HTTP::Request::Common qw(GET);
use Time::Local;
use FindBin qw($Bin);
our $MT4_PATH = $Bin;
$MT4_PATH =~ s/script//;
our $ERR;
our $TIMEZONE = 7 * 3600; #hour

# exit;

require $Bin.'/config.pl';
require $Bin.'/history.pl';
our @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

sub process{
	my $out = 'ok;';
	my $tmp;
	my $save_file = 0;
	my $year = ((localtime)[5])+1900;
	my ($month, $day, $date, $currency, $prio, $desc, $act, $forc, $prev, $unit, $ts, $avarage, $goodeffect, $max, $power, $desc2, $dif, $len, $unknown, $save_data);
	
	$tmp = (localtime(time))[6];
	$ts = time - ($tmp * 86400);
	$day = (localtime($ts))[3];
	$month = (localtime($ts))[4];
	my $filename = 'Calendar-'.sprintf ("%4d-%02d-%02d", $year, $month + 1, $day).'.csv';
	$month = lc($months[$month]);
  
  my $ua = LWP::UserAgent->new;
  if( $PROXY ){
    $ua->proxy('http', $PROXY);
  }
	my $res = $ua->request(GET 'http://www.forexfactory.com/calendar.php?week='.$month.$day.'.'.$year);
	my $html = $res->{ _content };
  
  # print $html;
  # print 'http://www.forexfactory.com/calendar.php?week='.$month.$day.'.'.$year;
	
	# open(DAT,' > ppp.html') || die("Cannot Open File");
		# print DAT $html;
	# close(DAT);
	# exit;
	
	
	# for(@arr){
		# print $_."\n\n";
	# }
	# exit;
  
	$html =~ s/\s*\n\s*//g;
	$html =~ s/\s{2,}/ /g;
	
	$month = $day = $date = $prio = $desc = $ts = '';
	my @currencies = qw(EUR AUD GBP JPY USD);
  my @lines;
  while( $html =~ /<tr class="calendar_row" data-eventid="\d+">(.*?)<\/tr>/g ){
    $tmp = $1;
    @lines = ();
    while( $tmp =~ /<td(.*?)>(.*?)<\/td>/g ){
      push (@lines, $2);
    }
		
		if( $lines[0] =~ /<div.*>(\S{3}) (\d+)\s*<\/div>/ ){
			$day = $2;
			$date = $1.' '.$day.', '.$year;
			$month = getMonthId($1);
		}
    
		if( $lines[2] =~ /([A-Z]{3})/ ){
			$currency =  $1;
			if( !grep $_ eq $currency, @currencies ){
				next;
			}
		}else{
			$out = 'Wrong currency '.$lines[2];
			last;
		}
		
		if( $lines[3] =~ /title="(Medium|High|Low|Non-Economic)/ ){
			$tmp = $1;
			if( $tmp eq 'High' ){
				$prio = 3;
			}elsif( $tmp eq 'Medium' ){
				$prio = 2;
			}else{
				$prio = 1;
			}
		}else{
			$out = 'Wrong priority '.$lines[3];
			last;
		}
    
		if( $lines[1] =~ /(\d+):(\d+)(am|pm)/ ){
			$tmp = $1;
			if( $3 eq 'pm' ){
				$tmp += 12;
			}
			$ts = timelocal( 0, $2, $tmp-1, $day, $month, $year ) + $TIMEZONE;
      
		}elsif( $lines[1] =~ /(Postponed|Cancelled)/ ){
      next;
		}elsif( $lines[1] =~ /(Day \d+|All Day|Postponed|Cancelled|Tentative|\d{1,2}[a-z]{2}-\d{1,2}[a-z]{2})/ ){
			$ts = timelocal( 0, 0, 0, $day, $month, $year );
      $prio = 0;
		}else{
			$out = 'Wrong time '.$lines[0].$lines[1].$lines[2];
			last;
		}

		if( $lines[4] =~ /<div>\s*(.*)\s*<\/div>/ ){
			$desc = $1;
			$desc =~ s/;/:/g;
			$desc =~ s/\\/\//g;
			$desc =~ s/'/\\'/g;
		}else{
			$out = 'Missing description '.$lines[4];
			last;
		}
		
    if( $lines[6] =~ /<span (.*?)>(.*?)<\/span>/ ){
      $lines[6] = $2;
    }
    if( $lines[6] =~ /<div (.*?)>(.*?)<\/div>/ ){
      $lines[6] = $2;
    }
    $lines[6] = trim($lines[6]);
		if( $lines[6] eq '' ){
			$act = '-';
		}elsif( $lines[6] =~ /(-?\d+\.?\d*)(\D*)$/ ){
			$unit = $2;
			$act = $1;
		}else{
			$out = 'wrong actual data '.$lines[6];
			last;
		}
		
		if( $lines[7] =~ /<span (.*?)>(.*?)<\/span>/ ){
      $lines[7] = $2;
    }
    if( $lines[7] =~ /<div (.*?)>(.*?)<\/div>/ ){
      $lines[7] = $2;
    }
    $lines[7] = trim($lines[7]);
		if( $lines[7] eq '' ){
			$forc = '-';
		}elsif( $lines[7] =~ /(-?\d+\.?\d*)(\D*)$/ ){
			$forc = $1;
		}else{
			$out = 'wrong actual data '.$lines[7];
			last;
		}
		
		if( $lines[8] =~ /<span (.*?)>(.*?)<\/span>/ ){
      $lines[8] = $2;
    }
    if( $lines[8] =~ /<div (.*?)>(.*?)<\/div>/ ){
      $lines[8] = $2;
    }
    $lines[8] = trim($lines[8]);
		if( $lines[8] eq '' ){
			$prev = '-';
		}elsif( $lines[8] =~ /(-?\d+\.?\d*)(\D*)$/ ){
			$prev = $1;
		}else{
			$out = 'wrong actual data '.$lines[8];
			last;
		}
		
		$goodeffect = '-';
    $power = 0;
		if( $act ne '-' && $forc ne '-' && $act =~ /^-?\d+\.?\d*$/ ){
			$avarage = 0;
			$dif = abs( $act - $forc );
			$max = $dif;
			$save_data = 1;
			
			for my $k1 ( keys %$HISTORY_DATA ){
				if( $HISTORY_DATA->{ $k1 }->{ CURRENCY } eq $currency && $HISTORY_DATA->{ $k1 }->{ DESC } eq $desc ){
					$goodeffect = $HISTORY_DATA->{ $k1 }->{ GOODEFFECT };
					$len = scalar keys %{$HISTORY_DATA -> { $k1 } -> { HISTORY }};
          
					for my $k2 ( keys %{$HISTORY_DATA->{ $k1 }->{ HISTORY }} ){
						if( $HISTORY_DATA->{ $k1 }->{ HISTORY } -> { $k2 } -> { DATE } eq $date ){
							$save_data = 0;
						}
						$tmp = abs( $HISTORY_DATA->{ $k1 }->{ HISTORY } -> { $k2 } -> { ACT } - $HISTORY_DATA->{ $k1 }->{ HISTORY } -> { $k2 } -> { FORC } );
						$avarage += $tmp;
						if( $tmp > $max ){
							$max = $tmp;
						}
					}
					
					if( $save_data == 1 ){
						$HISTORY_DATA->{ $k1 }->{ HISTORY } -> { $len } -> { DATE => $date, ACT => $act, FORC => $forc, PREV => $prev };
						$save_file = 1;
						$avarage += $dif;
						$len++;
					}
          
          if( $act == $forc ){
            $goodeffect = $goodeffect.'!';
						$power = 0;
            last; # break loop no need more iteration
            
          }else{
            $avarage = $avarage / $len;
            if( $dif > $avarage ){
							if( $dif > $max * 0.75 ){
								$power = 3;
							}else{
								$power = 2;
							}
            }else{
              $power = 1;
            }
            
            if( ($goodeffect eq 'A>F' && $act < $forc) || ($goodeffect eq 'A<F' && $act > $forc) ){
              $power = $power * -1;
            }
          }
          
					last; # break loop no need more iteration
				}
			}
			
			# if( $unknown == 1 ){
				# $max = $avarage = 0;
				# $power = 0;
			# }
			
		}
    # else{
			# $power = 0;
			# $avarage = $max = $unknown = 0;
		# }
		
		if( $power == 0 ){
			$desc2 = '-';
		}else{
      $max = sprintf("%.2f", $max );
      $max += 0;
      $avarage = sprintf("%.2f", $avarage );
      $avarage += 0;
      $dif = sprintf("%.2f", $dif );
      $dif += 0;
   
			$desc2 = '('.$max.'|'.$avarage.'|'.$dif.')'.$unit;
		}
		
		$desc = '('.$act.'|'.$forc.'|'.$prev.')'.$unit.' '.$desc;
		$out .= $currency.';'.$ts.';'.$desc.';'.$prio.';'.$goodeffect.';'.$power.';'.$desc2."\n";
	}
	
	if( $save_file == 1 ){
		saveHistoryData();
	}
	
	# print $out;
	$out !~ s/[^[:ascii:]]//g;
	open(DAT,' > '.$MT4_PATH.'experts/files/'.$filename) || die("Cannot Open File");
		print DAT $out;
	close(DAT);
}

sub getMonthId{
	for( my $i = 0; $i <= $#months; $i++ ){
		if( $months[$i] eq $_[0] ){
			return $i;
		}
	}
	return -1;
}

sub read_file{
  open(DATA, $_[0]);
  my @lines = <DATA>;
  close(DATA);
  return @lines;
}

sub saveHistoryData{
	my $out = '';
	my $idx = 0;
	$out .= 'our $X = 0;'."\n";
	$out .= 'our $HISTORY_DATA = {'."\n";
	for my $k1 ( sort keys %$HISTORY_DATA ){
		$out .= '  $X++ => { '."\n";
		
		for my $k2 ( sort keys %{$HISTORY_DATA->{ $k1 }} ){
				if( $k2 eq 'HISTORY' ){
					$out .= '    '.$k2.'=> {'."\n";
					
					for my $k3 ( sort keys %{$HISTORY_DATA->{ $k1 }->{ $k2 }} ){
						$out .= '      '.$k3.'=> {'."\n";
						
						for my $k4 ( keys %{$HISTORY_DATA->{ $k1 }->{ $k2 } ->{ $k3 }} ){
							$out .= '        '.$k4.'=> \''.$HISTORY_DATA->{ $k1 }{ $k2 }{ $k3}{ $k4 }."',\n";
						}
						$out .= '      '.'},'."\n";
						
					}
					$out .= '    '.'},'."\n";
					
				}else{
					$out .= '    '.$k2.'=> \''.$HISTORY_DATA->{ $k1 }{ $k2 }."',\n";
				}
		}
		$out .= "  },\n";
	}
	$out .= "};\n";
	$out .= '1;';
	
	open(DAT," > history.pl") || die("Cannot Open File");
		print DAT $out;
	close(DAT);
}

sub trim($){
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

process();


