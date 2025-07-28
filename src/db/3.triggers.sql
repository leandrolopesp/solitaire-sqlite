/* 
 SPDX-License-Identifier: CC-BY-NC-4.0
 Copyright (c) Leandro Lopes Pereira. Some rights reserved.
 See LICENSE file for full details.
*/


DROP TRIGGER IF EXISTS trgDealCard;
CREATE TRIGGER trgDealCard
BEFORE INSERT ON Moves
WHEN NEW.Action='deal'
AND  NEW.Source IS NULL
AND  NEW.Target IS NULL

BEGIN
    -- Deal the next card from stock pile to waste
    -- This update affects all stock pile cards simultaneously (intentional design)
    -- SQLite doesn't support variables, so it's not possible to store the current waste card temporarily to compute the next one.
    UPDATE Deck
    SET IsWasteTop = (
        SortOrder = (
            SELECT MIN(d.SortOrder)
            FROM Deck d
            WHERE d.InStock
            AND   d.SortOrder > (SELECT COALESCE(MAX(SortOrder), -1) 
                                 FROM   Deck
                                 WHERE  IsWasteTop
                                 AND    InStock)
        )
    )
    WHERE InStock;
END;


----------------------------------------------------

DROP TRIGGER IF EXISTS trgMoveWasteToTableau;
CREATE TRIGGER trgMoveWasteToTableau
BEFORE INSERT ON Moves
WHEN coalesce(NEW.ACTION,'move') = 'move'
AND  NEW.Target IS NOT NULL
BEGIN
    -- Move the top waste card to the tableau (except Kings)
    -- Must satisfy:
    -- - Alternating color
    -- - Rank one less than the top card in the target column

    UPDATE Deck
    SET FaceUp     = True,
        TableauCol = NEW.Target,
        TableauRow = 1 + (SELECT TableauRow FROM Tableau_Tops WHERE TableauCol = NEW.Target)
    WHERE Rank < 13  -- Exclude Kings
    AND (Suit, Rank) = (SELECT  d.Suit, d.Rank
                         FROM   Deck d
                         JOIN   Tableau_Tops t
                           ON   d.Rank = t.Rank - 1
                          AND   d.Color != t.Color
                          AND   d.IsWasteTop
                          AND   t.TableauCol = NEW.Target);

    -- Move waste pointer to the previous card
    UPDATE Deck
    SET IsWasteTop = (SortOrder = (SELECT MAX(SortOrder)
                                   FROM   Deck d
                                   WHERE  SortOrder < (SELECT SortOrder FROM Deck WHERE IsWasteTop = 1)
                                   AND    InStock))
    WHERE changes() > 0;
END;

----------------------------------------------------

DROP TRIGGER IF EXISTS trgMoveWasteKingToEmptyTableau;
CREATE TRIGGER trgMoveWasteKingToEmptyTableau
BEFORE INSERT ON Moves
WHEN NEW.Target IS NOT NULL
AND  NOT EXISTS (SELECT 1 FROM Tableau_Tops WHERE TableauCol = NEW.Target)
BEGIN
    -- Move King (Rank = 13) from waste to empty tableau column

    UPDATE Deck
    SET FaceUp     = True,
        TableauRow = True,
        TableauCol = NEW.Target
    WHERE Rank = 13
    AND   IsWasteTop;

    -- Move waste pointer to the previous card
    UPDATE Deck
    SET IsWasteTop = (SortOrder = (SELECT MAX(SortOrder)
                                   FROM Deck d
                                   WHERE SortOrder < (SELECT SortOrder FROM Deck WHERE IsWasteTop = 1)
                                   AND InStock))
    WHERE changes() > 0;
END;


----------------------------------------------------

DROP TRIGGER IF EXISTS trgMoveToFoundation;
CREATE TRIGGER trgMoveToFoundation
BEFORE INSERT ON Moves
WHEN NEW.Action = 'to-foundation'
BEGIN
    -- Move card from Waste to Foundation
    UPDATE Deck
    SET    InFoundation = True
    WHERE  new.source IS NULL
    AND    IsWasteTop
    AND    EXISTS (SELECT 1
                   FROM   Foundation f
                   WHERE  Deck.Suit = f.Suit
                   AND    Deck.Rank = f.Rank + 1);

    -- If moved from Waste, advance Waste pointer
    UPDATE Deck
    SET IsWasteTop = (SortOrder = (SELECT MAX(SortOrder)
                                   FROM Deck d
                                   WHERE SortOrder < (SELECT SortOrder FROM Deck WHERE IsWasteTop)
                                   AND   InStock))
    WHERE changes() > 0;

    -- Move card from Tableau to Foundation
    UPDATE Deck
    SET   InFoundation = True,
          TableauRow   = NULL,
          TableauCol   = NULL
    WHERE new.source IS not NULL
    AND   (Suit, Rank) IN (SELECT d.Suit, d.Rank
                            FROM   Tableau_Tops d
                            JOIN   Foundation f
                              ON   d.Suit = f.Suit
                             AND   d.Rank = f.Rank + 1
                            WHERE  d.TableauCol = NEW.Source);
END;


----------------------------------------------------

DROP TRIGGER IF EXISTS trgMoveFromFoundation;
CREATE TRIGGER trgMoveFromFoundation
BEFORE INSERT ON Moves
WHEN NEW.Action = 'from-foundation'
AND   NEW.Source  IS NOT NULL
AND   NEW.Target  IS NOT NULL
BEGIN
    -- Move a card from Foundation to Tableau
    -- Rules:
    -- - If card is King (13), it moves to an empty column
    -- - If not a King, it must stack onto a card with:
    --     - opposite color
    --     - rank exactly one higher (e.g., 9 onto 10)

    UPDATE Deck
    SET   InFoundation = False,
          FaceUp       = True,
          TableauCol   = NEW.Target,
          TableauRow   = COALESCE(
                              (SELECT TableauRow
                               FROM   Tableau_Tops 
                               WHERE  TableauCol = NEW.Target) + 1,
                              1 -- First row if the column is empty (for Kings)
                          )
    WHERE (Suit, Rank) IN (SELECT Suit, Rank
                            FROM   Foundation
                            WHERE  Col = NEW.Source)
    AND (
            -- Rule for non-Kings: must stack on existing card with opposite color and rank +1
            (Rank < 13 AND EXISTS (
                SELECT 1
                FROM   Tableau_Tops
                WHERE  TableauCol = NEW.Target
                AND    Color != Deck.Color
                AND    Rank  = Deck.Rank + 1
            ))
            OR
            -- Rule for Kings: column must be empty
            (Rank = 13 AND NOT EXISTS (
                SELECT 1
                FROM   Tableau_Tops
                WHERE  TableauCol = NEW.Target
            ))
        );
END;

----------------------------------------------------

DROP TRIGGER IF EXISTS trgMoveTableau;
CREATE TRIGGER trgMoveTableau
BEFORE INSERT ON Moves
WHEN   NEW.Action = 'move'
AND    NEW.Source IS NOT NULL
AND    NEW.Target IS NOT NULL
BEGIN

    -- Move stack of cards from Tableau Source to Target
    -- Rule 1: If King (13), can move to empty column
    -- Rule 2: Otherwise, must stack onto a card of opposite color and value exactly one higher

    -- Standard move (non-Kings, respecting color and order rules)
    UPDATE Deck
    SET   TableauCol = NEW.Target,
          TableauRow = 
              (SELECT TableauRow FROM Tableau_Tops WHERE TableauCol = NEW.Target) + 
              (TableauRow - (SELECT MIN(TableauRow)
                             FROM   Deck
                             WHERE  TableauCol = NEW.Source
                             AND    FaceUp
                             AND    Rank < (SELECT Rank FROM Tableau_Tops WHERE TableauCol = NEW.Target)
                            )) + 1,
          FaceUp = True
    WHERE TableauCol = NEW.Source
    AND   FaceUp 
    AND EXISTS (SELECT 1
                FROM   Tableau_Tops t
                WHERE  t.TableauCol = NEW.Target
                AND    Deck.Rank < t.Rank
                AND    t.Color != (SELECT Color
                                   FROM Deck
                                   WHERE TableauCol = NEW.Source
                                   AND   FaceUp
                                   AND   Rank = t.Rank - 1)
               );

    -- Special case: moving King (13) to empty column
    UPDATE Deck
    SET    TableauCol = NEW.Target,
           TableauRow = (TableauRow - (SELECT MIN(TableauRow)
                                       FROM   Deck
                                       WHERE  TableauCol = NEW.Source
                                       AND    FaceUp)) + 1,
          FaceUp = True
    WHERE TableauCol = NEW.Source
    AND   FaceUp
    AND   13 = (SELECT MAX(Rank)
                FROM   Deck 
                WHERE  TableauCol = NEW.Source
                AND    FaceUp)
    AND NOT EXISTS (SELECT 1
                    FROM Tableau_Tops t
                    WHERE t.TableauCol = NEW.Target);

END;

----------------------------------------------------

DROP TRIGGER IF EXISTS trgRevealTableauTop;
CREATE TRIGGER trgRevealTableauTop
AFTER INSERT ON Moves
WHEN NEW.Source IS NOT NULL
BEGIN
    -- Reveals tableau cards when the covering card is moved (auto-flip face-down cards)
    UPDATE Deck
    SET    FaceUp = True
    WHERE  (Suit, Rank) IN (SELECT Suit, Rank FROM Tableau_Tops)
    AND    not FaceUp;
END;


----------------------------------------------------

DROP TRIGGER IF EXISTS trgNewGame;
CREATE TRIGGER trgNewGame
AFTER INSERT ON Moves
WHEN NEW.Action = 'new'
BEGIN
    -- Clear the current game and reset the deck
    DELETE FROM Deck;
    DELETE FROM Moves;

    INSERT INTO Deck (Suit, Rank, SortOrder, TableauCol, TableauRow, FaceUp, IsWasteTop)
    SELECT Suit, Rank, cards.SortOrder, TableauCol, TableauRow, FaceUp, (cards.SortOrder = 29) IsWasteTop
    FROM (      
        SELECT suit,
               rank,
               ROW_NUMBER() OVER (ORDER BY random()) AS SortOrder  -- Randomize card order
        FROM (
            SELECT * 
            FROM (SELECT column1 AS suit FROM (VALUES ('♠'), ('♣'), ('♥'), ('♦'))) Suits

            CROSS JOIN (
                SELECT rank 
                FROM (  -- workaround for SQLite not allowing CTEs in triggers, generates ranks 1 to 13 using row_number() over sqlite_master
                    	SELECT ROW_NUMBER() OVER (ORDER BY name) AS rank 
                  		FROM sqlite_master) 
                WHERE rank <= 13) AS ranks
        )
    ) AS Cards
    LEFT JOIN (
        SELECT col.value AS TableauCol, row.value AS TableauRow,
               ROW_NUMBER() OVER (ORDER BY col.value, row.value) AS SortOrder,
               CASE WHEN col.value = row.value THEN 1 ELSE 0 END AS FaceUp
        FROM -- workaround for SQLite not allowing CTEs in triggers, generate 7x7 grid with FaceUp flags
            (SELECT value FROM (SELECT ROW_NUMBER() OVER (ORDER BY name) AS value FROM sqlite_master) WHERE value <= 7) col,
            (SELECT value FROM (SELECT ROW_NUMBER() OVER (ORDER BY name) AS value FROM sqlite_master) WHERE value <= 7) row
        WHERE row.value <= col.value
        ORDER BY 1, 2
    ) AS tableau
    ON cards.SortOrder = tableau.SortOrder;
END;

----------------------------------------------------

DROP TRIGGER IF EXISTS trgReset;
CREATE TRIGGER trgReset
AFTER INSERT ON Moves
WHEN NEW.Action = 'reset'
BEGIN
    -- Restart the current game, keeping the initial deck order
    DELETE FROM Moves;

    UPDATE Deck
    SET IsWasteTop = (SortOrder = 29),
        InFoundation = 0,
        TableauCol = (
            SELECT Value
            FROM (
                SELECT ROW_NUMBER() OVER (ORDER BY Col.Value, Lin.Value) AS SortOrder, Col.Value
                FROM (SELECT ROW_NUMBER() OVER (ORDER BY name) AS Value FROM sqlite_master LIMIT 7) AS Col,
                     (SELECT ROW_NUMBER() OVER (ORDER BY name) AS Value FROM sqlite_master LIMIT 7) AS Lin
                WHERE Lin.Value <= Col.Value
            ) col
            WHERE col.SortOrder = Deck.SortOrder
        ),
        TableauRow = (
            SELECT Value
            FROM (
                SELECT ROW_NUMBER() OVER (ORDER BY Col.Value, Lin.Value) AS SortOrder, Lin.Value
                FROM (SELECT ROW_NUMBER() OVER (ORDER BY name) AS Value FROM sqlite_master LIMIT 7) AS Col,
                     (SELECT ROW_NUMBER() OVER (ORDER BY name) AS Value FROM sqlite_master LIMIT 7) AS Lin
                WHERE Lin.Value <= Col.Value
            ) lin
            WHERE lin.SortOrder = Deck.SortOrder
        );

    UPDATE Deck SET FaceUp = IFNULL(TableauCol = TableauRow, 0);
END;