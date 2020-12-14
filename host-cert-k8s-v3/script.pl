#!/usr/bin/perl

open(FD, "pic01-rucio-server_pic_es_interm.cer");

while (<FD>) {
    $aux.=$_;

    if ($_=~'END CERTIFICATE'){
        push @certs, $aux;
        $aux='';
    }   
}

while ($aux=(pop @certs)){
    print $aux;
}
