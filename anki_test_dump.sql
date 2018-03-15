PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
DROP TABLE IF EXISTS col;
CREATE TABLE col (
        crt integer not null,
        mod integer not null,
        models text not null,
        decks text not null,
        tags text not null
      );
INSERT INTO col VALUES(1480996800,1514655628599,'{"1507832105615":{"name":"Basic (and reversed card)","did":1,"flds":[{"name":"Front","ord":0},{"name":"Back","ord":1}],"mod":1507832120,"id":1507832105615},"1482844395181":{"name":"en_de","did":1482060876072,"flds":[{"name":"English","ord":0},{"name":"German","ord":1},{"name":"Hint","ord":2}],"mod":1498897458,"id":1482844395181},"1482842770192":{"name":"de_reverse","did":1482060876072,"flds":[{"name":"German","ord":0},{"name":"English","ord":1},{"name":"Hint","ord":2}],"mod":1514653350,"id":1482842770192},"1502629924060":{"name":"Cloze","did":1,"flds":[{"name":"Text","ord":0},{"name":"Extra","ord":1}],"mod":1502629944,"id":1502629924060},"1482844263685":{"name":"de_en","did":1482060876072,"flds":[{"name":"German","ord":0},{"name":"English","ord":1},{"name":"Hint","ord":2}],"mod":1503554742,"id":1482844263685},"1498897408555":{"name":"preposition_case","did":1482060876072,"flds":[{"name":"Front","ord":0},{"name":"Back","ord":1}],"mod":1507832118,"id":1498897408555}}','{"1":{"name":"Default","mod":1482840611,"id":1},"1482060876072":{"name":"DE","mod":1514645269,"id":1482060876072},"1503955755113":{"name":"Thai","mod":1514645455,"id":1503955755113}}','{"sentence":0,"marked":0,"duplicate":0,"verb":0,"to-restructure":0,"verified-by-vanessa":0,"leech":0}');
DROP TABLE IF EXISTS notes;
CREATE TABLE notes (
      id integer not null,
      mod integer not null,
      mid integer not null,
      tags text not null,
      flds text not null,
      sfld text not null
      );
INSERT INTO notes VALUES(1506600417828,1506600429,1482842770192,'','Unnützunuseful','unuseful');
INSERT INTO notes VALUES(1506600526101,1506600538,1482842770192,'','reizento irritate (skin)','to irritate (skin)');
INSERT INTO notes VALUES(1506600538252,1506600547,1482842770192,'','empfindlichsensitive','sensitive');
INSERT INTO notes VALUES(1512715798553,1512715815,1482842770192,'','Die Einigungthe agreement','the agreement');
INSERT INTO notes VALUES(1513143152957,1513143174,1482842770192,'','großzügiggenerous','generous');
DROP TABLE IF EXISTS cards;
CREATE TABLE cards (
          id integer not null,
          nid integer not null,
          did integer not null,
          mod integer not null,
          ord integer not null,
          type integer not null,
          queue integer not null,
          due integer not null,
          reps integer not null,
          lapses integer not null
          );
INSERT INTO cards VALUES(1506600429296,1506600417828,1482060876072,1510927123,0,2,2,412,6,0);
INSERT INTO cards VALUES(1506600429297,1506600417828,1482060876072,1514058424,1,2,2,417,13,2);
INSERT INTO cards VALUES(1506600538241,1506600526101,1482060876072,1510071661,0,2,2,392,7,0);
INSERT INTO cards VALUES(1506600538242,1506600526101,1482060876072,1514507902,1,2,2,390,28,5);
INSERT INTO cards VALUES(1506600547120,1506600538252,1482060876072,1511668181,0,2,2,400,11,1);
INSERT INTO cards VALUES(1506600547121,1506600538252,1482060876072,1513616525,1,2,2,393,22,3);
INSERT INTO cards VALUES(1512715815757,1512715798553,1482060876072,1514331998,0,2,2,415,3,0);
INSERT INTO cards VALUES(1512715815760,1512715798553,1482060876072,1514420948,1,2,2,395,10,2);
INSERT INTO cards VALUES(1513143174755,1513143152957,1482060876072,1513946204,0,2,2,395,5,0);
INSERT INTO cards VALUES(1513143174757,1513143152957,1482060876072,1514507882,1,2,2,396,8,1);
COMMIT;
