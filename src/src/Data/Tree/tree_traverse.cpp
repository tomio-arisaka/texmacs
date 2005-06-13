
/******************************************************************************
* MODULE     : tree_traverse.cpp
* DESCRIPTION: abstract cursor movement and tree traversal
* COPYRIGHT  : (C) 2005  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license and comes WITHOUT
* ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for more details.
* If you don't have this file, write to the Free Software Foundation, Inc.,
* 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
******************************************************************************/

#include "tree_traverse.hpp"
#include "drd_std.hpp"

path
next_node (tree t, path p) {
  (void) t; return p;
}

path
previous_node (tree t, path p) {
  (void) t; return p;
}

path
next (tree t, path p) {
  (void) t; return p;
}

path
previous (tree t, path p) {
  (void) t; return p;
}

path
next_word (tree t, path p) {
  (void) t; return p;
}

path
previous_word (tree t, path p) {
  (void) t; return p;
}
