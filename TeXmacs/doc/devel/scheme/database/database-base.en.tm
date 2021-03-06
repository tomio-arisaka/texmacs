<TeXmacs|1.99.2>

<style|tmdoc>

<\body>
  <tmdoc-title|The <TeXmacs> database model>

  The <TeXmacs> database manipulation API has mainly been designed for
  internal use. It is based on a<nbsp>dedicated
  <hlink|NoSQL|http://en.wikipedia.org/wiki/NoSQL>-style database model,
  using a variant of <hlink|column data stores|http://en.wikipedia.org/wiki/Column_%28data_store%29>.
  For the moment, we only support a limit number of entry types and field
  types, although new types can easily be added later. Currently, databases
  are used for managing remote files, bibliographies, user lists, versions,
  etc.

  The interface has been kept to be as simple as possible, so that our low
  level implementation can be most easily optimized for efficiently when
  needed. Furthermore, the routines of our basic API can all be customized
  <em|a posteriori> to add specific features. For instance, the basic API is
  string-based, so a<nbsp>special additional layer was added to support
  <TeXmacs> snippets as values instead of strings. Similarly, an additional
  layer was added for managing the permissions of specific users. The
  advantage of this design based on <em|a posteriori> customizations is that
  the routines in the basic API always keep the same semantics, no matter how
  many additional layers are added.

  A <TeXmacs> database is always a collection of database <em|entries>. Each
  entry consists of a <em|unique identifier> and a list of <em|fields>. Each
  field consists of an <em|attribute>, a list of <em|values>, a <em|creation
  date> and an <em|expiration date>. The creation and expirationd dates
  cannot be manipulated directly, but it is possible to specify an
  alternative time for database queries, which make it possible to easily
  recover any past state of the database.

  <paragraph|Macros for context specification>

  <\explain>
    <scm|(with-database db . body)><explain-synopsis|specify a database>
  <|explain>
    Execute <scm|body> with <scm|db> as the current database. Here <scm|db>
    should be an URL with extension <verbatim|.tmdb>. The database <scm|db>
    will be used by all routines of the database API called from within
    <scm|body>.
  </explain>

  <\explain>
    <scm|(with-time t . body)><explain-synopsis|specify a time>
  <|explain>
    Execute <scm|body> with <scm|t> as the current time. All database queries
    inside <scm|body> become relative to the time<nbsp><scm|t>, which allows
    for the inspection of past states of the database. The parameter <scm|t>
    is an integer representing a UNIX time stamp, or <scm|:now>. Any
    modifications of the database require <scm|:now> to be specified as the
    current time.
  </explain>

  <\explain>
    <scm|(with-time-stamp on? . body)><explain-synopsis|add date field to new
    entries>
  <|explain>
    Whenever <scm|on?> holds, a <scm|date> attribute will automatically be
    added to all newly created entries which do not already contain a
    <scm|date> field. For entries which circulate among several users, this
    allows you to determine when they were created for the first time.
  </explain>

  <\explain>
    <scm|(with-extra-fields l . body)><explain-synopsis|add fields to
    entries>
  <|explain>
    Whenever a new entry with fields <scm|new-l> is created inside
    <scm|body>, the list of fields <scm|l> is automatically added to
    <scm|new-l>, but only for attributes which were not already present in
    <scm|new-l>.
  </explain>

  <\explain>
    <scm|(with-limit limit . body)><explain-synopsis|limit number of return
    values>
  <|explain>
    For queries of the database inside <scm|body>, limit the number of
    returned values to <scm|limit>.
  </explain>

  <paragraph|Special attributes>

  <\description>
    <item*|<scm|name>>A name (or key) for the entry, by which it can referred
    to.

    <item*|<scm|date>>Creation date stamp for the entry, as determined by
    <scm|with-time-stamp>.
  </description>

  <paragraph|Main routines of the database API>

  <\explain>
    <scm|(db-set-field id attr vals)><explain-synopsis|set values for a given
    field>
  <|explain>
    For the field with atrribute <scm|attr> in the entry with identifier
    <scm|id>, set the values to <scm|vals>.
  </explain>

  <\explain>
    <scm|(db-get-field id attr)><explain-synopsis|get all values for a given
    field>
  <|explain>
    Get the list of values for the field with atrribute <scm|attr> in the
    entry with identifier <scm|id>.
  </explain>

  <\explain>
    <scm|(db-get-attributes id)><explain-synopsis|get the list of attributes>
  <|explain>
    Get the list of attributes for the entry with identifier <scm|id>.
  </explain>

  <\explain>
    <scm|(db-set-entry id l)><explain-synopsis|fill out a complete entry>
  <|explain>
    For the entry with identifier <scm|id>, set the list of fields to
    <scm|l>.
  </explain>

  <\explain>
    <scm|(db-get-entry id)><explain-synopsis|retrieve a complete entry>
  <|explain>
    Get the list of fields for the entry with identifier <scm|id>.
  </explain>

  <\explain>
    <scm|(db-remove-entry id)><explain-synopsis|remove a complete entry>
  <|explain>
    Remove the entry with identifier <scm|id>.
  </explain>

  <\explain>
    <scm|(db-create-id)><explain-synopsis|create a unique identifier>
  <|explain>
    Create an identifier which does not yet exist in the database.
  </explain>

  <\explain>
    <scm|(db-search q)><explain-synopsis|search for a list of fields>
  <|explain>
    Return the list of identifiers of entries which match a given query
    <scm|q>. The query <scm|q> is a list of constraints of the form
    <scm|(attr val1 ... valn)>. Each constraint is interpreted as ``the
    attribute <scm|attr> of the entry is one of the values <scm|val1>,
    <math|\<ldots\>>, <scm|valn>''. In addition to these <em|basic>
    constraints, extensions of the database API may implement additional
    kinds of constraints. Such <em|supplementary> constraints are always
    formed by taking a special keyword for <scm|attr>.

    The basic API already implements one type of supplementary constraint of
    the form <scm|(:order attr asc?)>, where <scm|attr> is an attribute and
    <scm|asc?> a boolean value. This kind of supplementary constraint is
    always satisfied and has the effect of ordering the output of the query
    on the attribute <scm|attr> in ascending or descending order, depending
    on <scm|asc?>.
  </explain>

  <paragraph|Other useful routines>

  <\explain>
    <scm|(db-get-field-first id attr)><explain-synopsis|get first value for a
    given field>
  <|explain>
    Get the first value in <scm|(db-get-field id attr)> or <scm|#f>.
  </explain>

  <\explain>
    <scm|(db-create-entry l)><explain-synopsis|create a new entry>
  <|explain>
    Create a new entry in the current database with fields <scm|l>, and
    return the identifier of the newly created entry.
  </explain>

  <\explain>
    <scm|(db-entry-exists? id)><explain-synopsis|test existence of entry>
  <|explain>
    Test whether there exists an entry with identifier <scm|id>.
  </explain>

  <tmdoc-copyright|2015|Joris van der Hoeven>

  <tmdoc-license|Permission is granted to copy, distribute and/or modify this
  document under the terms of the GNU Free Documentation License, Version 1.1
  or any later version published by the Free Software Foundation; with no
  Invariant Sections, with no Front-Cover Texts, and with no Back-Cover
  Texts. A copy of the license is included in the section entitled "GNU Free
  Documentation License".>
</body>