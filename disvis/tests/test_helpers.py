from unittest import main, TestCase

from disvis.helpers import parse_ambiguous_restraints, RestraintParser


class TestHelpers(TestCase):

    def test_parse_ambiguous_restraints(self):
        line = 'restraint (1.A@CA or -2.B@DS3 or -4) (4.C@A) 0 10.3'
        parse_ambiguous_restraints(line)


class TestRestraintParser(TestCase):

    def test_parse_line(self):
        p = RestraintParser()
        line = 'restraint (1.A@CA or 2.B) (4.C or -8) 1 -10.4'
        r = p.parse_line(line)
        print r.receptor_selection
        

if __name__ == '__main__':
    main()
