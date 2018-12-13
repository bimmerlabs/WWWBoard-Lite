#!/usr/bin perl
use Mojolicious::Lite;

get '/' => sub { my $self = shift; my $post; $self->stash(post => $post); } =>
  'index';

get '/faq' => 'faq';

any '/post' => 'index';

app->start;

__DATA__

@@ index.html.ep
% layout 'default';
% title 'WWWBoard::Lite Version 1.0!';
  <div align="center">
      <h1>WWWBoard::Lite Version 1.0!</h1>
  </div>
  Below is WWWBoard::Lite Version 1.0 ALPHA 1.
  <hr size="7" width="75%">
  <center>[ <a href="#post">Post Message</a> ] [ <a href="<%= url_for 'faq' %>">FAQ</a> ]</center> <hr size=7 width=75%>

  <ul>
  (messages posted here)
  </ul>
<a name="post"><center><h2>Post A Message!</h2></center></a>
%= form_for post => begin
  %= label_for name => 'Name:'
  %= text_field name => $post->{name}, size => '50'
  <br>
  %= label_for email => 'E-mail:'
  %= text_field email => $post->{email}, size => '50'
  <p>
  %= label_for subject => 'Subject:'
  %= text_field subject => $post->{subject}, size => '50'
  </p>
  %= label_for message => 'Message:'
  <br>
  %= text_area message => $post->{message}, rows => '10', cols => '55'
  <p>
  %= label_for url => 'Optional Link URL:'
  %= text_field url => $post->{url}, size => '50'
  <br>
  %= label_for url_title => 'Link Title:'
  %= text_field url_title => $post->{url_title}, size => '50'
  <br>
  %= label_for img => 'Optional Image URL:'
  %= text_field img => $post->{img}, size => '50'
  </p>
  %= submit_button 'Post Message'
  %= tag 'input', type => 'reset'
% end
<br>(Original) scripts and WWWBoard created by Matt Wright and can be found at <%= link_to 'Matt\'s Script Archive', 'http://www.scriptarchive.com' %>
<br>WWWBoard::Lite can be found on <%= link_to 'GitHub', 'https://github.com/bimmerlabs/WWWBoard-Lite' %>

@@ faq.html.ep
% layout 'default';
% title 'WWWBoard::Lite Frequently Asked Questions';
<h1>WWWBoard::Lite Frequently Asked Questions and Answers</h1>
Here is a brief explanation of some of the questions you may have 
about WWWBoard.
<hr>
<ul>
<li><a href="#links">Can I use html tags anywhere in my posts?</a>
<li><a href="#colons">Why are there colons in the message section when I 
try post a followup?</a>
<li><a href="#reload">Why didn't my post show up?</a>
<li><a href="#getit">Where can I get the scripts for this program?</a>
</ul>
<hr>
<a name="links">Can I put html tags anywhere in my posts?</a>
<p>No.  You can not use HTML tags in any field except body of the message.  
The maintainer of the script has the option of allowing or 
disallowing any HTML in the Message part of your posting.  If 
they disallow it, the script will just throw out everything in 
&lt;&gt;'s.  If they allow it, your html markup will appear in 
the posting.  It can't hurt to try.</p> 
<hr>
<a name="colons">Why are there colons in the message when I try to post a 
followup?</a>
<p>Colons appear in the message dialog box when you try to followup up on a 
message to indicate that those lines are quoting the previous document. 
The owner of the WWWBoard can decide whether they wish to enable or 
disable the quoting of previous messages.</p>
<hr>
<a name="reload">Why didn't my post show up?</a>
<p>Your post most likely did not show up, because your browser did not reload the 
page, it simply pulled it out of cache.  Please reload your browser and it 
should then appear.</p>
<hr>
<a name="getit">Where can I get the scripts for this program?</a>
<p>The (original) scripts were written in Perl and created by <%= link_to 'Matt Wright', 'http://www.mattwright.com/' %>.  They are 
free to anyone who wishes to use them and you can get them as well as other 
scripts at: <%= link_to 'http://www.scriptarchive.com/' %>.</p>
<p>WWWBoard::Lite is a re-imagined version of the original scripts from 1995.  It is meant to look the same on the surface, but under the hood it is much, much differet - despite being written in the same language (Perl 5).  20+ years of improvements in both the Perl interpreter and coding practices make a big difference!  The source can be found on <%= link_to 'GitHub', 'https://github.com/bimmerlabs/WWWBoard-Lite' %></p>
<p>Enjoy!</p>
<hr>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= $title %></title></head>
  <body>

<%= content %>
    
  </body>
</html>
