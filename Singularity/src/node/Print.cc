#include "Print.hh"

#include "node.hh"

namespace SNode
{

llvm::Value* Print::codeGen(CodeGenContext& context)
{
	llvm::Value* expr = expression.codeGen(context);
	/*Set up printf arguments*/
	std::vector<llvm::Value*> printArgs;

	if(expr->getType()->isDoubleTy())
		printArgs.push_back(context.formatDouble);
	else if(expr->getType()->isIntegerTy())
		printArgs.push_back(context.formatInt);
	printArgs.push_back(expr);

	return context.builder.CreateCall(context.module->getFunction("printf"), printArgs);
}

void Print::print(size_t tabs) const
{
    printTabs(tabs);
    std::cout << "Print: " << std::endl;
    expression.print(tabs + 1);
}

void Print::createSymbolTable(SymbolTable&, std::string, size_t*) const
{
	// getExpressionType will manage the exception in case the symbol is not defined
    this->expression.getExpressionType();
    	
}

}
