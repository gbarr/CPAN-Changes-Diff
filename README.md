# CPAN::Changes::Diff

Find the changes file within a CPAN distribution and return the
difference bwtween two changes file.

Changes will be looked for in one of several filenames, Changes, ChangeLog
with no file extension or .txt or .pod

If the changes file is written in pod the result will be the difference
after formatting into plain text

This software is copyright (c) 2011 by Graham Barr <gbarr@cpan.org>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

