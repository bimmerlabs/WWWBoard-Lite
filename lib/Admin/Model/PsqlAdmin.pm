package Admin::Model::PsqlAdmin;
use Mojo::Base -base, -signatures;
no warnings qw(experimental::postderef);
use feature qw(postderef);

has 'pg';

sub new { bless {}, shift }

sub database {
  my $db = shift->pg->db;
  return $db;
}

sub date_time {
  my $self     = shift;
  my $db       = database($self);
  my $now      = $db->query('select now() as now')->hash;
  my $datetime = $now->{'now'};
  $datetime =~ s/\..*//;
  my ($date, $time) = split / /, $datetime;
  return ($date, $time, $datetime);
}

sub create_table {
  my $self  = shift;
   my $db = database($self);
  my $table = $self->param('table');
  $db->query("CREATE TABLE IF NOT EXISTS $table (id serial primary key);");
}

sub drop_table {
  my $self  = shift;
   my $db = database($self);
  my $table = $self->param('table');
  $db->query("DROP TABLE IF EXISTS $table;");
}

sub add_column {
  my ($self, $schema) = @_;
   my $db = database($self);
  my $table = $self->param('table');
  $db->query("ALTER TABLE $table ADD COLUMN IF NOT EXISTS $schema;");
  return 1;
}

sub drop_column {
  my $self   = shift;
   my $db = database($self);
  my $table  = $self->param('table');
  my $column = $self->param('column');
  $db->query("ALTER TABLE $table DROP COLUMN IF EXISTS \"$column\";");
}

sub rename_column {
  my $self = shift;
   my $db = database($self);
  my ($as_text, $query);
  if ($self->param('data_type')) {
    say 'set ' . $self->param('name') . ' to ' . $self->param('data_type');
    $query
      = 'ALTER TABLE '
      . $self->param('table')
      . ' ALTER COLUMN "'
      . $self->param('name')
      . '" SET DATA TYPE ';
      if (grep(/int/, $self->param('data_type'))) {
       $query = $query.$self->param('data_type') . ' USING addr::' . $self->param('data_type') . ';';
      }
      else {
        $query = $query.$self->param('data_type') . ';';
      }
    unless ($self->param('name') eq $self->param('newname')) {
      $query
        = $query
        . ' ALTER TABLE '
        . $self->param('table')
        . ' RENAME COLUMN "'
        . $self->param('name')
        . '" TO "'
        . $self->param('newname') . '";';
    }
  }
  else {
    $query
      = 'ALTER TABLE '
      . $self->param('table')
      . ' RENAME COLUMN "'
      . $self->param('name')
      . '" TO "'
      . $self->param('newname') . '";';
  }
  $db->query($query);
}

sub increment {
  my ($self, $table, $column, $where, $value) = @_;
   my $db = database($self);
   my $query = "UPDATE $table SET $column = $column + 1 WHERE $where = '$value';";
  $db->query($query);
  return 1;
}

sub update {
  my ($self, $table, $updates, $where) = @_;
  my $db = database($self);
  my $results = $db->update($table, $updates, $where, {returning => 'id'})->hash;
  return ($results->{'id'}) if defined $results->{'id'};
}

sub upsert {
  my ($self, $table, $where, $insert, $updates) = @_;
  my $db = database($self);
  my $id;
  # this does the same thing as an upsert (on conflict) but is probably slower
  my ($results) = find_one($self, $table, $where);
  if (defined $results->{'id'}) {
    ($id) = update($self, $table, $updates, {id => $results->{'id'}});
  }
  else {
    $id = $db->insert($table, $insert, {returning => 'id'})->hash->{id};
  }
  return $id;
}

sub edit_row {
  my $self = shift;

  my $table = $self->param('table');
  my $id    = $self->param('id');
  my $db = database($self);
  
  $self->req->params->remove($_) for qw/ table routename primarykey query _method /;
  my $params = $self->req->params->to_hash;
  my @query;
  foreach my $key (keys $params->%*) {
    unless ($key eq 'id') {
      my $value = $self->param($key);
      # in case large amounts of blank values are integers
      unless ($value || $key eq 'notes') { $value = '0' }
      $value =~ s/'/''/g;
      push(@query, "\"$key\" = '$value'");
    }
  }
  my $query = join(", ", @query);
  $db->query("UPDATE $table SET $query WHERE id = '$id';");
  return $params->{'id'};
}

sub add_row {
  my $self  = shift;
   my $db = database($self);
  my $table = $self->param('table');
  $self->req->params->remove($_) for qw/ table routename _method /;
  my $params = $self->req->params->to_hash;
  my (@names, @values);
  foreach my $key (keys $params->%*) {
    my $value = $self->param($key);
    unless ($value) {
      $value = '0';
    }
    push(@names, '"' . $key . '"');
    $value =~ s/'/''/g;
    push(@values, "'" . $value . "'");
  }
  my $names  = join(", ", @names);
  my $values = join(", ", @values);
  my $results
    = $db->query("INSERT INTO $table ($names) VALUES ($values) RETURNING id;")
    ->hash;
  return ($results->{'id'});
}

sub add_row_from_buffer {
  my ($self, $table, $buffer) = @_;
   my $db = database($self);
  $db->insert($table, $buffer);
  return 1;
}

sub copy_row {
  my $self = shift;
   my $db = database($self);
  return 1;
}

sub drop_row {
  my $self = shift;
   my $db = database($self);
  $db->delete($self->param('table'), {id => $self->param('id')});
  return 1;
}

sub list_all {
  my ($self, $offset, $limit, $column) = @_;
  my $db = database($self);
  my $table = $self->param('table');
  my %table;
  my @primarykeys;
  if ($column) {
    $column = "id, \"$column\"";
  }
  else {
    $column = '*';
  }
  if ($limit) {
    $limit = ' LIMIT ' . $limit; # $limit is uninitialized - what should a default be?
  }
  my $results
    = $db->query('SELECT '
      . $column
      . ' FROM '
      . $self->param('table')
      . ' WHERE id >= '
      . $offset
      . ' ORDER BY id'
      . $limit
      . ' OFFSET 0;');
  my $low
    = $db->query(
    'SELECT id FROM ' . $self->param('table') . ' ORDER BY id ASC LIMIT 1;')
    ->hash;
  my $high
    = $db->query(
    'SELECT id FROM ' . $self->param('table') . ' ORDER BY id DESC LIMIT 1;')
    ->hash;
  my $columns = $results->columns;
  my $rows    = $results->rows;
  while (my $next = $results->hash) {
    foreach my $key (keys $next->%*) {
      $table{$next->{'id'}}{$key} = $next->{$key};
    }
    if ($rows > 0) {
      push @primarykeys, ($next->{'id'});
      $rows--;
    }
  }
  @primarykeys = sort { $a <=> $b } @primarykeys;
  return (\%table, \@primarykeys, $columns, $results->rows, $low, $high);
}

sub find_many {
  my ($self, $table, $list, $opts) = @_;
  my $db = database($self);
  my (%table, @primarykeys);
  my $results = $db->select($table, undef, $list, $opts);
  my $columns = $results->columns;
  my $rows    = $results->rows;
  while (my $next = $results->hash) {
    foreach my $key (keys $next->%*) {
      $table{$next->{'id'}}{$key} = $next->{$key};
    }
    if ($rows > 0) {
      push @primarykeys, ($next->{'id'});
      $rows--;
    }
  }
  @primarykeys = sort { $a <=> $b } @primarykeys;
  return (\%table, \@primarykeys, $columns, $results->rows);
}

sub find_many_q {
  my ($self, $table) = @_;
   my $db = database($self);
  my %table;
  my @primarykeys;
  my $results = $db->select($table, undef, { $self->param('col_name') => { $self->param('operator') => $self->param('query') } });
  my $columns = $results->columns;
  my $rows    = $results->rows;
  while (my $next = $results->hash) {
    foreach my $key (keys $next->%*) {
      $table{$next->{'id'}}{$key} = $next->{$key};
    }
    if ($rows > 0) {
      push @primarykeys, ($next->{'id'});
      $rows--;
    }
  }
  @primarykeys = sort { $a <=> $b } @primarykeys;
  return (\%table, \@primarykeys, $columns, $results->rows);
}


sub find_many_q2 {
  my ($self, $table) = @_;
   my $db = database($self);
  my %table;
  my @primarykeys;   
  my $query = "SELECT * FROM $table";
  if ($self->param('dme') ne 'Any' && defined $self->param('dme')) {
    $query .= " WHERE dme = '". $self->param('dme') ."' AND (\"";
  }
  else {
    $query .= ' WHERE "';
  }
    if ($self->param('query1') || $self->param('operator1') eq 'IS NOT NULL') {
      $query .= $self->param('col1') .'" '. $self->param('operator1');
        $query .= " '". $self->param('query1') ."'";
    }
    if ($self->param('query2') || $self->param('operator2') eq 'IS NOT NULL') {
      $query .= ' '. $self->param('and2') .' "'. $self->param('col2') .'" '. $self->param('operator2');
        $query .= " '". $self->param('query2') ."'";
    }
    if ($self->param('query3') || $self->param('operator3') eq 'IS NOT NULL') {
      $query .= ' '. $self->param('and3') .' "'. $self->param('col3') .'" '. $self->param('operator3');
        $query .= " '". $self->param('query3') ."'";
    }
    if ($self->param('query4') || $self->param('operator4') eq 'IS NOT NULL') {
      $query .= ' '. $self->param('and4') .' "'. $self->param('col4') .'" '. $self->param('operator4');
        $query .= " '". $self->param('query4') ."'";
    }
  if ($self->param('dme') ne 'Any' && defined $self->param('dme')) {
    $query .= ')';
  }
  $query .= ';';
  my $results = $db->query($query);
  my $columns = $results->columns;
  my $rows    = $results->rows;
  while (my $next = $results->hash) {
    foreach my $key (keys $next->%*) {
      $table{$next->{'id'}}{$key} = $next->{$key};
    }
    unless ($table{$next->{'id'}}{'translation'}) {
      $self->param(table => 'translation');
      if (my ($translation) = find_one($self, 'translations', { name => $next->{'name'} })) {
        $table{$next->{'id'}}{'translation'} = $translation->{'translation'};
        $table{$next->{'id'}}{'translation_id'} = $translation->{'id'};
      }
    }

    if ($rows > 0) {
      push @primarykeys, ($next->{'id'});
      $rows--;
    }
  }
  @primarykeys = sort { $a <=> $b } @primarykeys;
  return (\%table, \@primarykeys, $columns, $results->rows);
}

sub select_all ($self, $table) {
  my $db = database($self);
  my (%table, @ids);

  my $results = $db->select($table);
  my $rows    = $results->rows;
  while (my $next = $results->hash) {
    foreach my $key (keys $next->%*) {
      $table{$next->{'id'}}{$key} = $next->{$key};
    }
    if ($rows > 0) {
      push @ids, ($next->{'id'});
      $rows--;
    }
  }
  @ids = sort { $a <=> $b } @ids;
  return (\%table, \@ids);
}

sub find_one {
  my ($self, $table, $list) = @_;
   my $db = database($self);
  my $results = $db->select($table, undef, {%{$list}});
  my $columns = $results->columns;
  if (my $results = $results->hash) {
    return ($results, $columns);
  }
}

# utilities

# find last inserted id
sub last_id {
  my ($self, $table, $list) = @_;
  my $db = $self->pg->db;
  my $results
    = $db->select($table, 'MAX(id)', $list)->text;
  return ($results);
}

# find total number of rows
sub total_rows {
  my ($self, $table, $list) = @_;
  my $db = $self->pg->db;
  my $rows
    = $db->select($table, 'COUNT(*)', $list)->text;
  return ($rows);
}

1;
