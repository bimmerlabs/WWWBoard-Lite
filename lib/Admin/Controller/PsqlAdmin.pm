package Admin::Controller::PsqlAdmin;
use Mojo::Base 'Mojolicious::Controller', -signatures;
no warnings qw(experimental::postderef uninitialized);
use feature qw(postderef);
use Admin::Model::PsqlAdmin;

sub new { bless {}, shift }

sub home ($c) {
      my ($rows, $last, $results);
      foreach ($c->config->{'tables'}->@*) {
        $rows->{$_} = Admin::Model::PsqlAdmin::total_rows($c, $_);
        $last->{$_} = Admin::Model::PsqlAdmin::last_id($c, $_);
        chomp $rows->{$_};
        chomp $last->{$_};
        if ($last->{$_}) {
          ($results->{$_}) = Admin::Model::PsqlAdmin::find_one($c, $_, { 'id' => $last->{$_} });
        }
      }
      $c->stash(
        rows => $rows,
        last_id => $last,
        results => $results
      );
  $c->render('/admin/index');
}

# database tools
sub list_all_rows ($c) {
  my $title = ucfirst $c->param('table');
  my ($offset, $limit) = split(/-/, $c->param('limits'));
  my $current = $offset;
  $offset = $offset - ($limit / 2);
  $offset = sprintf "%.0f", $offset;
  my ($results, $ids, $columns, $rows, $low, $high);
  if (defined $c->param('query')) {
   ($results, $ids, $columns, $rows) = Admin::Model::PsqlAdmin::find_many_q($c, $c->param('table'));
      $high->{'id'} = 999999;
      $low->{'id'}  =     0;
  }
  else {
    ($results, $ids, $columns, $rows, $low, $high) = Admin::Model::PsqlAdmin::list_all($c, $offset, $limit,
    $c->param('column'));
  }
  $c->stash(
    title   => $title,
    db      => $c->param('table'),
    results => $results,
    ids     => $ids,
    columns => $columns,
    rows    => $rows,
    limits  => $limit,
    current => $current,
    low     => $low->{'id'},
    high    => $high->{'id'}
  );
  if ($rows < 1) {
    $c->stash(message => 'Sorry, no results for that query.');
  }
  $c->render('admin/results');
}

sub list_single_row ($c) {
  my $title  = ucfirst $c->param('table');
  my $offset = $c->param('id') - ($c->param('limits') / 2);
  $offset = sprintf "%.0f", $offset;

  # add an action that matches if the :id parameter is a list like 90-100 etc.
  my ($results, $ids, $columns, $rows, $low, $high)
    = Admin::Model::PsqlAdmin::list_all($c, $offset, $c->param('limits'));

  # my ($schema) = Admin::Model::PsqlAdmin::get_schema($c);
  my @columns = $c->param('column');
  if ($c->param('column')) {
    $columns = \@columns;
  }
  $c->stash(
    title   => $title,
    db      => $c->param('table'),
    id      => $c->param('id'),
    results => $results,
    ids     => $ids,
    columns => $columns,
    column  => $c->param('column'),
    rows    => $rows,
    limits  => $c->param('limits'),
    low     => $low->{'id'},
    high    => $high->{'id'}
  );
  $c->render('admin/single_result');
}

sub remove_duplicates ($c) {
  # remove duplicate entries
  $c->subprocess(
    sub {
      my $subprocess = shift;
      Admin::Model::PsqlAdmin::remove_duplicates($c);
      return 'Done!';
    },
    sub {
      my ($subprocess, $results) = @_;
      say $results;
    }
  );
  $c->redirect_to('/admin');
}

sub add_table {
  my $c = shift;
  Admin::Model::PsqlAdmin::create_table($c);
  $c->redirect_to('/admin');
}

sub add_column {
  my $c   = shift;
  my $schema = '"' . $c->param('column') . '" ' . $c->param('data_type');
  if ($c->param('array')) {
    $schema .= '[]';
  }
  if ($c->param('constraint')) {
    $schema .= " NOT NULL";
    if ($c->param('defaultvalue')) {
      $schema .= " DEFAULT '" . $c->param('defaultvalue') . "'";
    }
    else {
      $schema .= " DEFAULT '0'";
    }
  }
  Admin::Model::PsqlAdmin::add_column($c, $schema);
  $c->redirect_to('/admin');
}

sub drop_column {
  my $c = shift;
  Admin::Model::PsqlAdmin::drop_column($c);
  $c->redirect_to('/admin');
}

sub rename_column {
  my $c = shift;
  Admin::Model::PsqlAdmin::rename_column($c);
  $c->redirect_to('/admin');
}

sub add_row {
  my $c      = shift;
  my $routename = $c->param('routename');
  my $id        = Admin::Model::PsqlAdmin::add_row($c);
  $c->flash(message => "<a href=\"#$id\">$id has been added.</a>");
  $c->redirect_to($routename);
}

sub drop_row {
  my $c      = shift;
  my $routename = '/' . $c->param('routename');
  Admin::Model::PsqlAdmin::drop_row($c);
  $c->flash(message => $c->param('id').' has been removed.');
  $c->redirect_to($routename);
}

sub edit_row {
  my $c      = shift;
  my $routename = $c->param('routename');
  my $id        = Admin::Model::PsqlAdmin::edit_row($c);
  $c->flash(message => "<a href=\"#$id\">Row $id has been updated.</a>");
  $c->redirect_to($routename);
}

1;