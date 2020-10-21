#ifndef NOT_OPERATION_H
#define NOT_OPERATION_H

#include "node.hh"

namespace SNode
{

class NotOperation : public Expression {
public:
    Expression& expression;
    NotOperation(Expression& expression) :
        expression(expression) { }
    virtual llvm::Value* codeGen(CodeGenContext& context);
    void print(size_t tabs = 0) const override;
    Datatype getExpressionType() const override;
};

}

#endif // NOT_OPERATION_H