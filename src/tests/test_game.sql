-- This script is used to test the Solitaire card game.
-- It cleans the game state and restarts with a specific deck and predefined moves.
-- The test must end in victory, with all cards moved to the foundation (deck.InFoundation = 1).

-- To run from command prompt:
-- sqlite3 solitaire.db < ./src/tests/test_game.sql

-- Alternatively, inside sqlite3:
--.read ./src/tests/test_game.sql
--.mode column

delete from deck;
delete from moves;

--First test
--Creates a new game.
INSERT INTO Moves (Action) VALUES('new');

-- Verifies new game setup correctness
select 'ERROR NEW GAME'
Where (28, 24, 7, 1, 0) NOT IN 
    (select sum(intableau)    intableau
          , sum(instock)      instock
          , sum(faceup)       faceup
          , sum(iswastetop)   iswastetop
          , sum(infoundation) infoundation
     from deck);

--------
--Deck--
--------
-- A fixed game
delete from deck;
-- Hidden tableau cards
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♥',2,2,2,1,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♦',7,4,3,1,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♦',8,5,3,2,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♣',11,7,4,1,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♣',1,8,4,2,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♦',9,9,4,3,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♣',13,11,5,1,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♣',7,12,5,2,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♣',8,13,5,3,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♥',5,14,5,4,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♠',7,16,6,1,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♥',11,17,6,2,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♦',6,18,6,3,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♥',12,19,6,4,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♥',1,20,6,5,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♠',12,22,7,1,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♣',9,23,7,2,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♦',13,24,7,3,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♣',2,25,7,4,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♠',8,26,7,5,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♠',9,27,7,6,0,0,0);
-- Revealed tableau cards (FaceUp)
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♦',1,1,1,1,0,1,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♠',10,3,2,2,0,1,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♠',6,6,3,3,0,1,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♣',4,10,4,4,0,1,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♦',3,15,5,5,0,1,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♠',2,21,6,6,0,1,0);
INSERT INTO Deck (Suit,Rank,SortOrder,TableauCol,TableauRow,InFoundation,FaceUp,IsWasteTop) VALUES('♥',10,28,7,7,0,1,0);

-- Stock pile
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♠',1,29,0,0,1);  
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♥',13,30,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♠',11,31,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♠',3,32,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♦',11,33,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♥',3,34,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♣',12,35,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♥',6,36,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♣',3,37,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♣',6,38,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♣',10,39,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♦',4,40,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♥',7,41,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♦',2,42,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♥',8,43,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♠',4,44,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♦',10,45,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♥',9,46,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♥',4,47,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♠',5,48,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♦',5,49,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♠',13,50,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♦',12,51,0,0,0);
INSERT INTO Deck (Suit,Rank,SortOrder,InFoundation,FaceUp,IsWasteTop) VALUES('♣',5,52,0,0,0);

---------
--Moves--
---------
INSERT INTO Moves (Action) VALUES('reset');                           --Reset game
INSERT INTO Moves (Action) VALUES('to-foundation');                   -- Move waste card to foundation
INSERT INTO Moves (Action) VALUES('deal');                            -- Deal next card
INSERT INTO Moves (Action,Source) VALUES('to-foundation',1);          -- Move from column 1 to foundation, leaving empty space
INSERT INTO Moves (Action,Source,Target) VALUES('move',6,5);          -- Move single card from column 6 to 5
INSERT INTO Moves (Action,Source,Target) VALUES('move',6,5);          -- Move another card from column 6 to 5
INSERT INTO Moves (Action,Source,Target) VALUES('move',5,4);          -- Move stack of 3 cards from column 5 to 4
INSERT INTO Moves (Target) VALUES(1);                                 -- Move waste card (K) to empty column 1
INSERT INTO Moves (Action,Source,Target) VALUES('move',4,5);
INSERT INTO Moves (Action,Source,Target) VALUES('move',5,3);
INSERT INTO Moves (Action,Source,Target) VALUES('move',5,4);
INSERT INTO Moves (Action,Source,Target) VALUES('move',4,2);
INSERT INTO Moves (Action,Source) VALUES('to-foundation',4);
INSERT INTO Moves (Action,Source,Target) VALUES('move',4,6);
INSERT INTO Moves (Action,Source,Target) VALUES('move',7,6);
INSERT INTO Moves (Action,Source,Target) VALUES('move',7,6);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action,Source) VALUES('to-foundation',3);
insert into Moves (Action,Source,Target) VALUES('from-foundation',3,3); -- Tests if the A card from column 2 of the foundation moves back to column 3 of the tableau.
INSERT INTO Moves (Action,Source) VALUES('to-foundation',3);
INSERT INTO Moves (Action,Source) VALUES('to-foundation',3);
INSERT INTO Moves (Action) VALUES('to-foundation');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(1);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(5);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(7);
INSERT INTO Moves (Action,Source,Target) VALUES('move',3,7);
INSERT INTO Moves (Action,Source,Target) VALUES('move',5,3);
INSERT INTO Moves (Action,Source,Target) VALUES('move',6,5);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('to-foundation');
INSERT INTO Moves (Action,Source) VALUES('to-foundation',7);
INSERT INTO Moves (Action) VALUES('to-foundation');
INSERT INTO Moves (Action,Source,Target) VALUES('move',3,5);
INSERT INTO Moves (Action,Source,Target) VALUES('move',3,2);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('to-foundation');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(6);
INSERT INTO Moves (Target) VALUES(6);
INSERT INTO Moves (Action,Source,Target) VALUES('move',6,5);
INSERT INTO Moves (Action,Source,Target) VALUES('move',5,3);             --Moves card sequence starting with K to empty slot on the tableau
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(4);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(4);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(6);
INSERT INTO Moves (Action) VALUES('to-foundation');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(4);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(1);
INSERT INTO Moves (Action,Source,Target) VALUES('move',2,1);
INSERT INTO Moves (Action,Source) VALUES('to-foundation',2);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('to-foundation');
INSERT INTO Moves (Action,Source) VALUES('to-foundation',3);
INSERT INTO Moves (Action,Source) VALUES('to-foundation',3);
INSERT INTO Moves (Action,Source,Target) VALUES('move',6,3);
INSERT INTO Moves (Action,Source) VALUES('to-foundation',6);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(1);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(6);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(4);
INSERT INTO Moves (Action) VALUES('deal');
INSERT INTO Moves (Target) VALUES(6);
INSERT INTO Moves (Action,Source,Target) VALUES('move',7,6);
INSERT INTO Moves (Action,Source) VALUES('to-foundation',7);
INSERT INTO Moves (Action,Source,Target) VALUES('move',7,2);
INSERT INTO Moves (Action,Source,Target) VALUES('move',7,4);
INSERT INTO Moves (Action,Source,Target) VALUES('move',7,2);
INSERT INTO Moves (Action,Source,Target) VALUES('move',6,2);
INSERT INTO Moves (Target) VALUES(4);
INSERT INTO Moves (Action,Source,Target) VALUES('move',6,4);
INSERT INTO Moves (Action) VALUES('to-foundation');
INSERT INTO Moves (Action,Source) VALUES('to-foundation',2),('to-foundation',3);
INSERT INTO Moves (Action,Source) VALUES('to-foundation',2);
insert into moves(action, source) values('to-foundation',1),('to-foundation',2),('to-foundation',3);
insert into moves(action, source) values('to-foundation',1),('to-foundation',2),('to-foundation',3),('to-foundation',4);
insert into moves(action, source) values('to-foundation',1),('to-foundation',2),('to-foundation',3),('to-foundation',4);
insert into moves(action, source) values('to-foundation',1),('to-foundation',2),('to-foundation',3),('to-foundation',4);
insert into moves(action, source) values('to-foundation',1),('to-foundation',2),('to-foundation',3),('to-foundation',4);
insert into moves(action, source) values('to-foundation',1),('to-foundation',2),('to-foundation',3),('to-foundation',4);
insert into moves(action, source) values('to-foundation',1),('to-foundation',2),('to-foundation',3),('to-foundation',4);
insert into moves(action, source) values('to-foundation',1),('to-foundation',2),('to-foundation',3),('to-foundation',4); 

INSERT INTO Moves (Action,Source,Target) VALUES('from-foundation',1,1); -- Test moving King from foundation back to tableau
INSERT INTO Moves (Action,Source) VALUES('to-foundation',1);

-- Display final game state
select * from game_view;