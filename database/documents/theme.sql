#### Configuration Document ####
INSERT INTO Documents VALUES (
'', 
'/config',
'System Configuration',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'');

#### Theme Documents ####

#### Default Theme ####
INSERT INTO Documents VALUES (
'', 
'/themes/default/header',
'Default theme header',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" 
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title>[% title %]</title>
    [% CSS %]
</head>

<body>
<table width="100%" border="0">
  <tr align="left" valign="top">
[% IF left_panels.size > 0 %]
  <td width="20%">
  [% FOREACH panel = left_panels %]
    <table width="100%" border="0">
      <tr>
        <td>
        [% INCLUDE $panel %]
        </td>
      </tr>
    </table>
  [% END %]
  </td>
[% END %]
  <td class=main width="80%">
');

INSERT INTO Documents VALUES (
'', 
'/themes/default/footer',
'Default theme footer',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'
  </td>

[% IF right_panels.size > 0 %]
  <td width="20%">
  [% FOREACH panel = right_panels %]
    <table width="100%" border="0">
      <tr>
        <td>
        [% INCLUDE $panel %]
        </td>
      </tr>
    </table>
  [% END %]
  </td>
[% END %]

</tr>
</table>
<hr>
<p align="right">Generated by Apache::Onanox for 
[% user.realname %] ([% user.username %])<br>
&copy; 2002, Russell Matbouli</p>
</body>
</html>
');

INSERT INTO Documents VALUES (
'', 
'/themes/default/config',
'Default theme configuration',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'');

#### Blank Theme ####
INSERT INTO Documents VALUES (
'', 
'/themes/blank/header',
'Blank theme header',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" 
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title>[% title %]</title>
    [% CSS %]
</head>

<body>
');

INSERT INTO Documents VALUES (
'', 
'/themes/blank/footer',
'Blank theme footer',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'');

INSERT INTO Documents VALUES (
'', 
'/themes/blank/config',
'Blank theme configuration',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'');

#### Email Theme ####
INSERT INTO Documents VALUES (
'', 
'/themes/email/header',
'Email theme header',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'');

INSERT INTO Documents VALUES (
'', 
'/themes/email/footer',
'Email theme footer',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'-- 
An Apache::Onanox production.');

INSERT INTO Documents VALUES (
'', 
'/themes/email/config',
'Email theme configuration',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'');

#### Bordered Theme ####
INSERT INTO Documents VALUES (
'', 
'/themes/borders/header',
'Borders theme header',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" 
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title>[% title %]</title>
    [% CSS %]
</head>

<body>
<table width="100%" border="1">
  <tr align="left" valign="top">
[% IF left_panels.size > 0 %]
  <td width="20%">
  [% FOREACH panel = left_panels %]
    <table width="100%" border="1">
      <tr>
        <td>
        [% INCLUDE $panel %]
        </td>
      </tr>
    </table>
  [% END %]
  </td>
[% END %]
  <td width="80%">
');

INSERT INTO Documents VALUES (
'', 
'/themes/borders/footer',
'Borders theme footer',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'
  </td>
[% IF right_panels.size > 0 %]
  <td width="20%">
  [% FOREACH panel = right_panels %]
    <table width="100%" border="1">
      <tr>
        <td>
        [% INCLUDE $panel %]
        </td>
      </tr>
    </table>
  [% END %]
  </td>
[% END %]
</tr>
</table>

</body>
</html>
');

INSERT INTO Documents VALUES (
'', 
'/themes/borders/config',
'Borders theme configuration',
'0',
'1',
'',
'',
'parsed',
'1',
'0',
'');
