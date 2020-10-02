#include "Piece.h"

#ifndef KING_H
#define KING_H

class King : public Piece
{
  public:
  	King(char symbol);

  	/*!
    * @details Determine all the possible cells to which the
    *	     king can move. It checks cells in all adjacent squares
    * @return an std::vector with all the moves that the king can
    *		  do moving to the upper left, upper right, lower left
    *		  and lower right, left, right, up and down
    */
    MoveTypes getPossibleMoves() override;
};

#endif 