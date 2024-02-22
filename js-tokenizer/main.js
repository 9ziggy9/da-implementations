const fs = require('fs');
const readline = require('readline');

async function consumeFile(filename) {
  const fileStream = fs.createReadStream(filename, {
    encoding: "utf8"
  });
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });
  for await (const line of rl) {
    for (const token of lexer(line)) console.log(token);
  }
}

const isWhiteSpace = (char) => /\s/.test(char);

function* lexer(line) {
  for (const char of line) {
    if (isWhiteSpace(char)) yield {type: "WHITESPACE"};
    else {
      switch (char) {
      case '(': yield {type: "LEFT_PAREN"};  break;
      case ')': yield {type: "RIGHT_PAREN"}; break;
      case '+': yield {type: "OP_ADD"};      break;
      case '-': yield {type: "OP_SUB"};      break;
      case '*': yield {type: "OP_MUL"};      break;
      case '/': yield {type: "OP_DIV"};      break;
      case '%': yield {type: "OP_MOD"};      break;
      default:  yield {type: "UNRECOGNIZED"};
      }
    }
  }
}

consumeFile("src.txt");
