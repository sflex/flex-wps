package AUBBC2;
use strict;
use warnings;
#use re 'debugcolor';

our $VERSION     = 1.02;

our $MEMOIZE     = 1; # use MEMOIZE Default on
#our $DEBUG      =  0; # Debugger for more info, not used
our $CONFIG      = 0; # Config file path
our @TAGS        = (); # Main Tags[array]{hash}
our %REGEX       = (); # Regex hash
our %AUBBC       = (); # AUBBC hash settings
# ACCESS_LOG - If the user did not have access for
# a tag this will send errors to error_message.
our $ACCESS_LOG  =  0; # Default off
our $DELIMITER   = ('-' x 40); # delimiter for tag list
our $FOR_LINKS   = 0; # set link to 1 if the tag is a type of link or 0 if not
our $BYPASS      = 1; # can use #none #bbcode#utf#smileys to stop those groups

# settings for script_escape and html_to_text
our $ESCAPE      = 1; # Use script_escape Default on.
our $LINE_BREAK  = 1; # changes line break for script_escape and html_to_text
our $HTML_TYPE   = ' /'; # adds slash to line break script_escape and html_to_text
our $NO_PRETTY   = 0; # formats text more. for script_escape and html_to_text

my $aubbc_error     = undef; # Module errors
my $add_reg         = undef; # cache for fast regex
my $settings_cache  = undef; # cache for %AUBBC regex
my $mem_flag        = undef; # Load MEMOIZE once
my @security_levels = ('Guest', 'User', 'Moderator','Administrator');
my ($user_level, $user_key) = ('Guest', 0);

sub security_levels {
 my ($self,@s_levels) = @_;
 $user_key = undef; # Reset security policy
 @s_levels ? @security_levels = @s_levels
  : return @security_levels;
}

sub user_level {
 my $self = shift;
 my $u_level = shift;
 $user_key = undef; # Reset security policy
 defined $u_level ? $user_level = $u_level
  : return $user_level;
}

sub check_access { # faster
my $tag_id = shift;
# change the security policy
 unless (defined $user_key) {
  for (0 .. $#security_levels) { # loop through base security levels
   # Match current users security level name with base security names
   if ($security_levels[$_] eq $user_level) {
    $user_key = $_; # give them the number
    last;
    }
   }
  }

  # if security exists for this tag
  if (defined $TAGS[$tag_id]{security}) {
  $user_key >= $TAGS[$tag_id]{security} # is user security equal or higher?
   ? return 1 # security good
   : return 0 ; # security bad
   } else {
    # no security for this tag
    return 1;
    }
}

sub new {
#my $class = shift; # ok, but slow
#my $self = bless {}, $class;  # ok, but slow
 if ($MEMOIZE && ! defined $mem_flag ) {
  $mem_flag = 1;
  require Memoize if (! defined $Memoize::VERSION);
  if (defined $Memoize::VERSION) {
   Memoize::memoize('add_tag');
   Memoize::memoize('parse_bbcode');
   Memoize::memoize('script_escape') if ! $ESCAPE;
   Memoize::memoize('html_to_text');
   Memoize::memoize('add_settings');
  }
 }

# Load a config file
require $CONFIG if defined $CONFIG && $CONFIG;

 #return $self; # ok, but slow
 return bless {}; # faster
}

sub DESTROY {

}

# could help speed things up
sub add_a_setting {
my $self = shift;
my $hash_name = shift;
my $hashvalue = shift;
$settings_cache = undef;
$AUBBC{$hash_name} = $hashvalue
 if defined $hashvalue && defined $hashvalue;
}

sub add_settings {
my ($self,%s_hash) = @_;
$settings_cache = undef;
#$AUBBC{$_} = $s_hash{$_} foreach (keys %s_hash);
# faster then foreach, this is not void contex
map { $AUBBC{$_} = $s_hash{$_} } keys %s_hash;
}

sub get_setting {
 my $self = shift;
 my $name = shift;
 $name = (defined $name && defined $AUBBC{$name})
  ? $AUBBC{$name} : '';
  return $name;
}

sub remove_setting {
 my $self = shift;
 my $name = shift;
 $settings_cache = undef;
 delete $AUBBC{$name}
  if defined $name && defined $AUBBC{$name};
}

sub parse_bbcode {
  my $self = shift;
  local $_ = shift || '';

 if ($_) {
 $_ = $self->script_escape($_) if $ESCAPE;

# join hash names in $settings_cache for regex
# this way we do not call a foreach to get settings every tag
if (! defined $settings_cache) {
 $settings_cache = join('|', map { $_ }  keys %AUBBC );
 $settings_cache = qr/$settings_cache/x;
 }

# All 3 groups to be bypassed for \A#none mark.
 my ($bbcode, $utf, $smileys) = ($BYPASS && s{\A\#none}[]x)
        ? (1,1,1) : (0,0,0);
       
# #bbcode#utf#smileys bypass marks and order    # run order from top to bottom
 $bbcode  = 1 if $BYPASS && s{\A\#bbcode}[]x;      #1#0#1#1#0#1#0...
 $utf     = 1 if $BYPASS && s{\A\#utf}[]x;         #2#1#0#2#0#0#1...
 $smileys = 1 if $BYPASS && s{\A\#smileys}[]x;     #3#2#2#0#1#0#0...

  # loop through all TAGS.
  for my $i ( 0 .. $#TAGS ) {
   # no type = no work to do || for links skip
   next if ! defined $TAGS[$i]{type}
    || $FOR_LINKS && $TAGS[$i]{link};

   # no work to do for these types skip
   unless (m'\['x) {
   next if $TAGS[$i]{type} eq 'balanced'
   || $TAGS[$i]{type} eq 'linktag'
   || $TAGS[$i]{type} eq 'single';
   }

   # single group bypass
   if (defined $BYPASS &&($bbcode || $utf || $smileys)) {
   next if $utf && $TAGS[$i]{group} eq 'utf'
   || $bbcode && $TAGS[$i]{group} eq 'bbcode'
   || $bbcode && $TAGS[$i]{group} eq 'dbbcode'
   || $smileys && $TAGS[$i]{group} eq 'smileys';
   }

# In order by what will gain the most speed from next; because of high use
# balanced, linktag, single, strip
# Copy attribute
  my $attri_me = $TAGS[$i]{attribute} || '';

  # balanced
  if ($TAGS[$i]{type} eq 'balanced') {
   # Figure out if balanced has attributes
   $attri_me = ($attri_me =~ m'\A\-\|'x)
        ? qr'[= ].+?'x
        : qr'='x.$attri_me if $attri_me;
   # commen bbcode search
   if ($TAGS[$i]{group} ne 'dbbcode') {
   s{(\[(($TAGS[$i]{tag})$attri_me)\]($TAGS[$i]{message})\[\/\3\])}[
         my $ret = set_tag($i, $3, $4, $2); # set_tag
         $ret ? $ret : past_participle($1); # past_participle?
        ]giex;
        next;
   } # deeper bbcode search
    elsif ($TAGS[$i]{group} eq 'dbbcode') {
      1 while s{(\[(($TAGS[$i]{tag})$attri_me)\]($TAGS[$i]{message})\[\/\3\])}[
          my $ret = set_tag($i, $3, $4, $2); # set_tag
          $ret ? $ret : past_participle($1); # past_participle?
         ]giex;
         next;
        # next tag balanced is done
    }
 }# linktag
 elsif ($TAGS[$i]{type} eq 'linktag') {
  # Figure out if linktag has attributes
  $attri_me = qr'&#124;'x.$attri_me if $attri_me;
  s{(\[($TAGS[$i]{tag})\:\/\/($TAGS[$i]{message})($attri_me)\])}[
         my $ret = set_tag($i, $2, $3, $4); # set_tag
         $ret ? $ret : past_participle($1); # return or past
        ]giex;
        next;
        # next tag linktag is done
 }# single
  elsif ($TAGS[$i]{type} eq 'single') {
  s{(\[($TAGS[$i]{tag})\])}[
        my $ret = set_tag($i, $2, '', ''); # set_tag
        $ret ? $ret : past_participle($1); # return or past
        ]giex;
        next;
        # next tag single is done
 }# strip
  elsif ($TAGS[$i]{type} eq 'strip') {
  s{($TAGS[$i]{message})}[
         my $ret = set_tag($i, '', $1, ''); # set_tag
         $ret ? $ret : ''; # remove or replace
        ]gex;
      }
   } # for
  } # if message
 return $_;
}

sub past_participle {
local $_ = shift;
s{\[}[&#91;]x;
return $_;
}

sub set_tag {
 my $tag_id     = shift;
 my $tag        = shift;
 my $message    = shift;
 my $attrs      = shift;

 # tag security here
 if (check_access($tag_id)) {
 # copy, do not change @TAGS values
 my $markup = $TAGS[$tag_id]{markup};
 my $extra = $TAGS[$tag_id]{attribute};
 # 2 variables allows the function to have a switch like ability
 # The function gets the tags attribute data so the function can expand
 # the attribute matching method or use swap to bypass it.
 ($message,$markup) =
 $TAGS[$tag_id]{function}->( $TAGS[$tag_id]{type}, $tag, $message, $markup, $extra, $attrs )
  if ($TAGS[$tag_id]{function});

  # Start balanced attribute syntax matching
  if ($markup && $TAGS[$tag_id]{type} eq 'balanced' && $extra =~ s[^\-\|][]x) {
    my %list; # attributes list from tag
    # they should get the "odd" error to know their syntax is wrong
    # and it parses faster this way.
    # attribute syntax list
    my %xlist = map { split(m'/'x) } split(m','x, $extra);
    # clean up the tag name if its not= an attribute
    $attrs =~ s[^\Q$tag ][]x;
    # loop through all attributes for this tag
    for( split m'\ (?=\b\w+\b\=)'x, $attrs ) {
    # split for attribute name and value
        my($name, $value) = split m'='x;
    # why this is made this way is for speed, but does it all.
    # if the attribute exists and value passes validation
    # and adds to markup or blank markup and last loop.
        ( defined $xlist{ $name }
        && match_range( $xlist{$name}, $value )
        && $markup =~ s[X\{\b$name\b\}][$value]gx )
            or $markup = '', last;

        undef $list{ $name }; # log matched attributes
    }
   # if an attribute was not used this stops the tag from converting.
   $markup = '' if $markup
    && scalar(keys %list) ne scalar(keys %xlist);
   } # End balanced attribute syntax matching

 # balanced and linktag one attribute
   $extra = $attrs
   if ( $extra && $attrs =~ s[^(?:\b$tag\b\=|\&\#124\;)][]x
   && ( $TAGS[$tag_id]{type} eq 'balanced' || $TAGS[$tag_id]{type} eq 'linktag' ) );


  # All types can use but not all will have a value because of type
  if ($markup && $markup =~ m'\%'x) {
   # use $settings_cache in regex, capture the hash name for the setting
    $markup =~ s[\%(\b$settings_cache\b)\%][$AUBBC{$1}]gx
     if defined $settings_cache;
   
   $markup =~ s[\%\{\btag\b\}][lc($tag);]gex if $tag;
   $markup =~ s[\%\{\battribute\b\}][$extra]gx if $extra;
   $markup =~ s[\%\{\bmessage\b\}][$message]gx if $message;
   }

   # swap blank $markup with $message value
   # if function swap was used for any type.
  $markup = $message
   if (!$markup && $TAGS[$tag_id]{function} && $message);

 return $markup;
 }
  else {
  # No security access error
  $aubbc_error .=
  'Access Denied: Tag ID='.$tag_id.
  ' Security='.$security_levels[$TAGS[$tag_id]{security}].
  ', User-Security='.$security_levels[$user_key]."\n"
   if $ACCESS_LOG;
  # No security error text
   $TAGS[$tag_id]{error} =
   (defined $TAGS[$tag_id]{error})
    ? $TAGS[$tag_id]{error} : 'Access Denied';

   return $TAGS[$tag_id]{error};
  }
}

sub match_range {
 local $_ = shift;
 my $limited = shift;
 # number range n\{#-#\}
 if ($limited =~ m'^\d+$'x && m'^n\\\{(\d+)\-(\d+)\\\}$'x) {
   $limited >= $1 && $limited <= $2 ? return 1 : return 0;
 } # length only check l\{#\}
  if (m'^l\\\{(\d+)\\\}$'x) {
  length($limited) <= $1 ? return 1 : return 0;
 } # letter range l\{X-X\}
  if (m'^l\\\{([a-z])\-([a-z])\\\}$'xi) {
  $limited !~ m/^[\Q$1\E-\Q$2\E]+$/xi ? return 0 : return 1;
 } # preset character length check w\{#\}
  if (m'^w\\\{(\d+)\\\}$'x) {
  # we allow &#\w+; so dont be fooled.
   length($limited) <= $1
    && $limited =~ m'^[\w\ \-\.\,\!\?\_\:\+\@\$\*\/\&\#\;]+$'xi
    ? return 1 : return 0;
 } # word match/ regex expand w\{Word\?\}
  if (m'^w\\\{(.+?)\\\}$'x) {
  $limited =~ m/^(?:\Q$1)$/xi ? return 1 : return 0;
 }
  else { return 0; }
}

sub check_subroutine {
 my $self = shift;
 my $name = shift;
 defined $name && exists &{$name} && (ref $name eq 'CODE' || ref $name eq '')
   ? return \&{$name} : return '';
}

sub add_tag {
 my ($self,%NewTag) = @_;
 # set cache value for add_tag fast regex
 $add_reg = join('|', map { $_ } keys %REGEX)
  if ! $add_reg;

# check the functions subroutine
 if (defined $NewTag{function} && $NewTag{function}) {
  my $fun_name = $NewTag{function};
  $NewTag{function} = $self->check_subroutine($NewTag{function});
  $aubbc_error .=
  'Method: add_tag( \'function\' => Undefined subroutine); Name='.$fun_name."\n"
   if ! $NewTag{function};
 }

 # match hash regex name and add the regex value from that name
  $NewTag{message} =~ s{\A(\b$add_reg\b)\z}[$REGEX{$1}]x if $add_reg;
  $NewTag{attribute} =~ s{\A(\b$add_reg\b)\z}[$REGEX{$1}]x if $add_reg;
 # Push the new tag at the end of the @TAGS array
  push(@TAGS, {
   'tag'         => $NewTag{tag}        || '',
   'type'        => $NewTag{type}       || '',
   'link'        => $NewTag{link}       ||  0,
   'group'       => $NewTag{group}      || 'bbcode',
   'function'    => $NewTag{function}   || '',
   'security'    => $NewTag{security}   ||  0,
   'description' => $NewTag{description}|| '',
   'attribute'   => $NewTag{attribute}  || '',
   'message'     => $NewTag{message}    || '',
   'error'       => $NewTag{error}      || '',
   'markup'      => $NewTag{markup}     || '',
   });
}

sub tag_list {
 my $self = shift;
 my $type = shift || '';
 my $text = '@TAGS:'."\n".$DELIMITER."\n".add_list(@TAGS);
 $text = $self->script_escape($text) if $type eq 'html';
 return $text;
}

sub add_list {
 my @TAGS_a = @_;
 my $txt = '';
 use B qw(svref_2object);

 foreach my $id (0 .. $#TAGS_a) {
  next unless defined $TAGS_a[$id]{type};
  my $fun = '';
  if (defined $TAGS_a[$id]{function} && $TAGS_a[$id]{function}) {
   my $cv = svref_2object($TAGS_a[$id]{function});
   my $gv = $cv->GV;
   $fun = $gv->NAME;
   }

   my $security_level = '';
   my $security_error = '';
   $security_level = $security_levels[$TAGS[$id]{security}].' #'.$TAGS[$id]{security}
    if (defined $TAGS[$id]{security});
   $security_error = $TAGS[$id]{error}
    if (defined $TAGS[$id]{error});

  $txt .= <<"TEXT";
ID: $id
tag: $TAGS_a[$id]{tag}
type: $TAGS_a[$id]{type}
link: $TAGS_a[$id]{link}
group: $TAGS_a[$id]{group}
error: $security_error
message: $TAGS_a[$id]{message}
secuirty: $security_level
function: $fun
attribute: $TAGS_a[$id]{attribute}
description: $TAGS_a[$id]{description}
markup: $TAGS_a[$id]{markup}
$DELIMITER
TEXT
   }
 return $txt;
}

sub script_escape {
  my $self = shift;
  local $_ = shift || '';
  if ($_) {
  s[(&|;)][$1 eq '&' ? '&amp;' : '&#59;']gex;
  if (! $NO_PRETTY) {
   s{\t}[ &nbsp; &nbsp; &nbsp;]gx;
   s{\ \ }[ &nbsp;]gx;
  }
  s{"}[&#34;]gx;
  s{<}[&#60;]gx;
  s{>}[&#62;]gx;
  s{'}[&#39;]gx;
  s{\)}[&#41;]gx;
  s{\(}[&#40;]gx;
  s{\\}[&#92;]gx;
  s{\|}[&#124;]gx;

  ! $NO_PRETTY && $LINE_BREAK eq '2'
   ? s{\n}[<br$HTML_TYPE>]gx
   : s{\n}[<br$HTML_TYPE>\n]gx
    if ! $NO_PRETTY && $LINE_BREAK eq '1';
  }
 return $_;
}

sub html_to_text {
  my $self = shift;
  local $_ = shift || '';
 if ($_) {
  s{&amp;}[&]gx;
  s{&\#59;}[;]gx;
  if (! $NO_PRETTY) {
   s{\ &nbsp;\ &nbsp;\ &nbsp;}[\t]gx;
   s{\ &nbsp;}[  ]gx;
  }
  s{&\#34;}["]gx;
  s{&\#60;}[<]gx;
  s{&\#62;}[>]gx;
  s{&\#39;}[']gx;
  s{&\#41;}[\)]gx;
  s{&\#40;}[\(]gx;
  s{&\#92;}[\\]gx;
  s{&\#124;}[\|]gx;
  s{<br\ ?\/?>\n?}[\n]gx if $LINE_BREAK;
  }
 return $_;
}

sub error_message {
 my $self = shift;
 my $error = shift;
 defined $error && $error
  ? $aubbc_error .= $error."\n"
  : return $aubbc_error;
}

1;

__END__

=pod

=head1 ABSTRACT

BBcode parser engine with individual tag security, attribute validation,
customization markup template and more.

=head1 SYNOPSIS

      use AUBBC2;
      %AUBBC2::AUBBC       = ();# Module Settings
      $AUBBC2::MEMOIZE     =  1;# Speed up the module, good for any load.
      @AUBBC2::TAGS        = ();# Tags
      %AUBBC2::REGEX       = ();# regex for add_tag()
      $AUBBC2::CONFIG      = '';# Path to configuration file
      $AUBBC2::ESCAPE      =  1;# Use script_escape Default on
      $AUBBC2::ACCESS_LOG  =  0;# Default off, If the user did not have access
      $AUBBC2::DELIMITER   =  ('-' x 40);# Delimiter for tag list

      my $aubbc = AUBBC2->new();

     $aubbc->add_tag(
     'tag'         => '[bip]',          # Tag pattern regex'
     'type'        => 'balanced',       # Tag type balanced, single, linktag, strip.
     'link'        => 0,                # if the tag is a link set to 1 or 0 if not, works with $NO_LINKS
     'group'       => 'dbbcode',        # any name but bbcode, dbbcode, utf, smileys cant be bypassed.
     'security'    => 0,                # security level number
     'error'       => 'Access Denied',  # '' blank for unchanged, ' ' space to remove
     'function'    => '',               # Expand tags function with a Perl subroutine. 'Class::Sub'
     'description' => 'This tag does this.',
     'message'     => '.+?',            # message pattern regex
     'attribute'   => '',               # attribute pattern regex and attribute syntax matching.
     'markup'      => '<%{tag}>%{message}</%{tag}>', # Tags output
    );

      my $message = '[p][b]Foo[/b] [i]Bar[/i][/p]'; # bbcode
      print  $aubbc->parse_bbcode($message);

=head1 DESCRIPTION

There are no built-in tags. You need to configure all the tags you want this to do.
This module can make it easy to parse BBcode to almost any output you want. HTML#
is normally the choice and all the examples are in HTML# or text. This module gives
you a lot of control over each tag designed with individual tag security, attribute
validation, customization markup template and a method to expand the function of
any tag. It does a lot. As it is now the BBcode tags end up being a big list that
can be saved in a back-end or configuration file to be parsed. The attributes
syntax for 'attribute' should help to reduce the need to do regular-expressions
to validate attributes.

=head1 Configuration

For overall speed the best way to config AUBBC2 is to use the configuration file.
In the example config file there is every tag that AUBBC can do for AUBBC2 now.
There are a few changes to some of the tags that was done to program out some
bug work arounds or just made them work better. Bypass marks do not have no in them
they are now named #none #bbcode #utf #smilyes. All balanced type tags must
have matching names for it's ending tag, the Left and right image tags Old AUBBC
style [left_img]/f.gif[/img] now would have to be this style [left_img]/f.gif[/left_img].
Never use grouping regex (.) in the module, this module takes care of that. You
can use none-grouping (?:.) if needed.
Balanced tags have a special group named dbbcode, this is for deeper searching
then what /g can provide. Only use the dbbcode group as needed!
Bypass marks see groups bbcode and dbbcode as the same group.

Configure a [single] type tag

  {
  'tag' => 'br|hr',     # tag names to match
  'type' => 'single',   # type is [single]
  'link' => 1,          # can be used with single
  'group' => 'bbcode',  # can be used with single
  'security' => 0,      # can be used with single
  'error' => '',        # can be used with single
  'description' => 'br line break and hr thematic break tags.', # is just there for each tag
  'function' => '',     # can be used with single, has function swap
  'message' => '',      # Not used for single type
  'attribute' => '',    # Not used for single type
  'markup' => '<%{tag}%html_type%>', # output if function swap was not used
 }

Configure a strip type tag

  {
  'tag' => 'aubbc_escape',      # Not used in strip type
  'type' => 'strip',            # type is strip
  'link' => 0,                  # can be used with strip
  'group' => 'filter',          # can be used with strip
  'security' => 0,              # can be used with strip
  'error' => '',                # can be used with strip
  'description' => 'This tag can be used to escape tags so you can type [[http://place.com]] and that tag will not convert, will not convert //]]> pattern.',
  'function' => '',             # can be used to expand strip and can do swap
  'message' => qr'(?<!\/{2})\]{2}(?!>)', # What is used to match with strip type
  'attribute' => '',            # Not used in strip type
  'markup' => '%]temp]%&#93;',  # output if function swap was not used
 }
 
=head1 Internal Methods

List of methods and what they do or how to use them.

=head2 user_level

 Set the current users security level by name.

        $bbcode->user_level('Guest');

 Returns the current users security level name.

        my $user_level = $bbcode->user_level();
        
=head2 security_levels

 Change the base security levels to adhere by.

               # array number:     0        1          2           3
        $bbcode->security_levels('Guest', 'User', 'Moderator','Administrator');

 Returns the current security array.

        my @security_levels = $bbcode->security_levels();

=head2 check_access

 If there is tag security set for a tag this checks the users security.
 Only called at set_tag.

=head2 parse_bbcode

 Main parsing method.

=head3 single

 type => single
 tag: [tag]

=head3 balanced

 type => balanced
 tags: [tag]message[/tag] or [tag=attribute]message[/tag]
 syntax tags: [tag=x attr2=x attr3=x attr4=x...]message[/tag]
  or [tag attr1=x attr2=x attr3=x...]message[/tag]

 note: attribute would equal %{attribute} in the markup.
 syntax tags are tags found with attribute syntax matching.

=head3 linktag

 type => linktag
 tags: [tag://message] or [tag://message|attribute]

 note: attribute would equal %{attribute} in the markup

=head3 strip

 type => strip
 tags: replace or remove

=head2 past_participle

 Stops failed parsed tags from being parsed again.


=head2 set_tag

 Does all the magic for all the tags.
 function, markup, tags, attrs, matching.

=head2 match_range

 Switches logic for attribute range matching.

=head2 check_subroutine

 Only returns a defined Perl subroutine or defined nothing.

=head2 add_tag

 Add tags to @TAGS, one at a time.
 1) This method will check the function if it exists.
 2) Fast regex hash import from %REGEX can be used in message
 and attribute, any, src, href. Or if you have changed the names then those
 can be used instead.

   $bbcode->add_tag(
     'tag'         => 'name|tag_name|etc', # Tag pattern regex
     'type'        => 'balanced', # Tag type balanced, single, linktag, strip.
     'link'        => 1, # if the tag is a link set to 1 or 0 if not, works with $no_links
     # and can be used for tags that would not come out well if you where to use the text
     # in a link. This is so you can configure for what will come out better in this situation
     # and not have to think about it later just change a value for the filter skip.
     'group'       => 'filter', # any name but #bbcode, #utf, #smileys cant be bypassed.
     'security'    => 0, # security level number
     'error'       => 'Access Denied', # '' blank for unchanged, ' ' space to remove
     'function'    => 'Class::Sub', # Expand tags function with a Perl subroutine.
     'description' => 'This tag does this.',
     'message'     => 'regex', # message pattern regex
     'attribute'   => 'regex', # attribute pattern regex and attribute syntax matching.
     'markup'      => '%{tag} %{message} %AUBBC_settings% X{attribute_name}', # Tags output
    );

=head2 tag_list

 Returns the main @TAGS list in text or html

        print $bbcode->tag_list('html');

=head2 add_list

 Returns a tag list in text

=head2 Remove a tag

 Remove tags by ID
 ID starts at 0 and is the array number of the @AUBBC2::TAGS list.

        delete @AUBBC2::TAGS[$ID];

 This can shift the ID number of some tags and since there is a hash in the array
 there can also be an autovivification issue with the array numbers.

=head2 clear_tags

 Clears all tags
 
        @AUBBC2::TAGS = ();

=head2 script_escape

 Makes all text safe to view in html

        $html = $bbcode->script_escape($text);

=head2 html_to_text

 Converts html codes back to text

        $text = $bbcode->html_to_text($html);

=head2 version

 Returns the version.
 Get it these two ways

        print AUBBC2->VERSION;

        or

        print $AUBBC2::VERSION;

=head2 error_message

 Add to error message. Each error message is
 separated by a line break \n. so do not include \n.

        $bbcode->error_message(
          'Some Error'
        );

 Returns all error messages separated by a line break \n

        $errors = $bbcode->error_message();

=head1 Tag Security

This is not SSX protection. This is a user security level to give security groups access
to tags. Set 'security' in the tag to 0 will default the tag to guest security. The
security group names can be changed.

The example config tags where tested for SSX and should have the same or better
protection then AUBBC. SSX security in this module is based on how the tag was made
and if a filter like script_escape was used can help out a lot.

=head2 Adding Tags

     $aubbc->add_tag(
     'tag'         => 'b|i|p',          # Tag pattern regex
     'type'        => 'balanced',       # Tag type balanced, single, linktag, strip.
     'link'        => 0,                # if the tag is a link set to 1 or 0 if not, works with $no_links
     # and can be used for tags that would not come out well if you where to use the text in a link.
     'group'       => 'bbcode',         # any name but bbcode, utf, smileys cant be bypassed.
     'security'    => 0,                # security level number
     'error'       => 'Access Denied',  # '' blank for unchanged, ' ' space to remove
     'function'    => 'Class::Sub',     # Expand tags function with a Perl subroutine.
     'description' => 'This tag does this.',
     'message'     => 'any',            # message pattern regex
     'attribute'   => '',               # attribute pattern regex and attribute syntax matching.
     'markup'      => '<%{tag}>%{message}</%{tag}>', # Tags output
    );

Type name:              Tag style

single                  [tag]

balanced		[tag]message[/tag] or [tag=attribute]message[/tag] or [tag attr=x...]message[/tag] or [tag=x attr=x...]message[/tag]

linktag			[tag://message] or [tag://message|attribute]

strip                   replace or remove

Tag name:
This allows a single tag added to change many tags and supports more complex regex:

        # This is an example of bold, italic and paragraph in the same add_tag()
        # Tags: [b]message[/b] or [i]message[/i] or [p]message[/p]
        # Output: <b>message</b> or <i>message</i> or <p>message</p>
      $aubbc->add_tag(
        'tag'         => 'b|i|p',          # Tag pattern regex
        'type'        => 'balanced',       # Tag type balanced, single, linktag, strip.
        'link'        => 0,                # if the tag is a link set to 1 or 0 if not, works with $no_links
        # and can be used for tags that would not come out well if you where to use the text in a link.
        'group'       => 'bbcode',         # any name but bbcode, utf, smileys cant be bypassed.
        'security'    => 0,                # security level number
        'error'       => 'Access Denied',  # '' blank for unchanged, ' ' space to remove
        'function'    => 'Class::Sub',     # Expand tags function with a Perl subroutine.
        'description' => 'This tag does this.',
        'message'     => 'any',            # message pattern regex
        'attribute'   => '',               # attribute pattern regex and attribute syntax matching.
        'markup'      => '<%{tag}>%{message}</%{tag}>', # Tags output
        );

Function:
In add_tag the name gets check to make sure its a defined subroutine then gets
passed these variables from the tag and tag database.

        sub new_function {
        # $tag, $message, $attrs are the captured group of its place
        # $type is the tags type from the tags hash
        # $markup is the output data from the tags hash
        # $extra is the attribute regex or syntax data from the tags hash
         my ($type, $tag, $message, $markup, $extra, $attrs) = @_;

         # expand functions....

         # A) If there is a $message and blank $markup the $message will replace the tag
         # with the function swap. Function swap will bypass attribute validation.
         # B) If there is both $message and $markup, then $message can be inserted
         # into $markup if $markup has %{message} or any "Markup Template Tags",
         # then markup will replace the tag and can go through attribute validation.
         # C) If both are blank the tag doesn't change.

         return ($message, $markup);
        }

Message:
Allows regex or fast regex for 'any', 'href', 'src' from add_tag only

href->  protocal://location/web/path/or/file

src->  protocal://location/web/path/or/file or /local/web/path/or/file

attribute: supports -> any href src

Balanced allows regex after tag= and linktag after message| or if negative pipe
is in front will switch to the attribute syntax for attribute range matching.
Only balanced tags can use the built-in attribute range matching syntax, but you
can use function to expand the validation method for any tag.

Attributes syntax and rules:

-Rules

-1) -|  must be at the beginning of 'attribute'

-2) All attributes listed in 'attribute' must be used and only used one time for
the tag to convert.

-3) The tag will not convert if an attribute does not validate, a function can
be used to expand the validation method for that tag and/or to bypass validation
with function swap.

-4) Do not use extra delimiters like / \{ \} and , in 'attribute', use as needed
you should get an "odd" Perl error if you have to many / or ,
and some warnings in higher Perl versions if the curly brackets are not escaped.

Attribute syntax in the preferred quote:

    '-|attribute_name/switch\{range\},attribute_name2/switch\{range\}'

Switches:

n\{0-0000\} = Number range n\{1-10\} means any number from 1 to 10

w\{0000\}   = Word range character pre-set limit is '\w -.,!?_:+@$*/&#;' w\{5\} means text 5 in length or less

w\{xx|xx\}  = Word match w\{This|That\} will match 'this' or 'That' and supports regex in w\{regex\}

l\{x-y\}    = Letter range with no length check l\{a-c\} means any letters from a to c

l\{0000\}   = Length check l\{5\} means text 5 in length or less

note: usage of X{attribute_name} in the markup will be replaced with the value
if everything is correct.

        # tag: [video height=90 width=115]http://www.video.com/video.mp4[/video]
        # output: <video width="115" height="90" controls="controls">
        #<source src="http://www.video.com/video.mp4" type="video/mp4" />
        #Your browser does not support the video tag.
        #</video>
        $aubbc->add_tag(
        'tag'         => 'video',
        'type'        => 'balanced',
        'link'        => 1,                # this is a type of link
        'group'       => 'bbcode',         # most tags are bbcode
        'security'    => 0,
        'error'       => '',
        'function'    => '',
        'description' => 'This is the [video height=# width=#]/video.mp4[/video] tag.',
        'message'     => 'src',
        'attribute'   => '-|width/n\{90-120\},height/n\{60-90\}',
        'markup'      => '<video width="X{width}" height="X{height}" controls="controls">
        <source src="%{message}" type="video/mp4" />
        Your browser does not support the video tag.
        </video>',
        );

Markup:

This is the template of the tag and has tags of its own giving you more control

Markup Template Tags:

Tag:            Info

%setting%       Any setting name in AUBBC2's main setting hash %AUBBC

%{tag}          Tag value

%{message}      Message value

%{attribute}        Extra value for non-attribute syntax

X{attribute_name}    Attribute names for values of attribute syntax

=head1 COPYLEFT

AUBBC2.pm, v1.02 08/04/2016 By: N.K.A.

shakaflex [at] gmail.com

https://github.com/sflex/AUBBC

http://search.cpan.org/~sflex/

Advanced Universal Bulletin Board Code 2

BBcode parser engine with individual tag security, attribute validation,
customization markup template and more.

Tested on Perl 5.8 and 5.22. The higher Perl version you go,
the faster this module should run. High speeds use Memoize.
Not tested but Memoize may or may not be good for mod_perl or Plack.


=head1 Development Guidance

http://www.perlmonks.com/

http://perldoc.perl.org/

=cut
