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
    const tokens = Array.from(lexer(line));
    try {
      const result = evaluate(tokens);
      console.log(result);
    } catch (e) {
      console.error("Error in evaluation.");
    }
  }
}

const isWhiteSpace = (char) => /\s/.test(char);
const isDigit = (char) => char >= '0' && char <= '9';
function* lexer(line) {
  for (let [i, char] of Array.from(line).entries()) {
    if (isWhiteSpace(char)) {
        yield { type: "WHITESPACE" };
    } else if (isDigit(char)) {
        // Handle potential multi-digit integers
        let numberStr = char;
        while (isDigit(line[i + 1])) {
            i++;
            numberStr += line[i];
        }
        const number = parseInt(numberStr);
        yield { type: "PRIM_INT", value: number };
    } else {
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

function evaluate(tokens) {
  const stack = [];
  for (const token of tokens) {
    if (token.type === "PRIM_INT") {
      stack.push(token.value);
    } else if (token.type === "OP_ADD") {
      const b = stack.pop();
      const a = stack.pop();
      stack.push(a + b);
    } else {
      // Handle other operators similarly
      // ...
    }
  }

  if (stack.length !== 1) {
    throw new Error("Invalid expression");
  }

  return stack[0];
}

consumeFile("src.txt");
