use strict;
use warnings;

use Test::More;
use DBI;
$|= 1;

my $rows = 0;
my $sth;
my $testInsertVals;
use vars qw($test_dsn $test_user $test_password);
use lib 't', '.';
require 'lib.pl';

my $dbh = DbiTestConnect($test_dsn, $test_user, $test_password,
                      { RaiseError => 1, PrintError => 0, AutoCommit => 0 });
plan tests => 110;

ok(defined $dbh, "Connected to database");

ok($dbh->do("DROP TABLE IF EXISTS dbd_mysql_t35"), "making slate clean");

ok($dbh->do("CREATE TABLE dbd_mysql_t35 (id INT(4), name VARCHAR(64))"), "creating table");

ok(($sth = $dbh->prepare("INSERT INTO dbd_mysql_t35 VALUES (?,?)")));

for my $i (0..99) {
  my @chars = grep !/[0O1Iil]/, 0..9, 'A'..'Z', 'a'..'z';
  my $random_chars = join '', map { $chars[rand @chars] } 0 .. 16;

  # save these values for later testing
  $testInsertVals->{$i} = $random_chars;
  ok(($rows = $sth->execute($i, $random_chars)));
}

ok($sth = $dbh->prepare("SELECT * FROM dbd_mysql_t35 LIMIT ?, ?"),
  'testing prepare of select statement with LIMIT placeholders');

ok($sth->execute(20, 50), 'testing exec of bind vars for limit');

my ($array_ref);
ok( (defined($array_ref = $sth->fetchall_arrayref) &&
  (!$sth->err)));

ok(@$array_ref == 50);

ok($dbh->do("DROP TABLE dbd_mysql_t35"));

ok($dbh->disconnect);
