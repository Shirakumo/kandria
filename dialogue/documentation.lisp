(in-package #:org.shirakumo.fraf.kandria.dialogue.components)

(docs:define-docs
  (type jump
    "A component representing a jump to another component.

See ORG.SHIRAKUMO.MARKLESS.COMPONENTS:TARGET")
  
  (type conditional
    "A component representing a conditional execution path.

See CLAUSES")

  (function clauses
    "Accesses a vector of clauses for the conditional component.

Each entry in the vector is a cons of a predicate and child
components.

See CONDITIONAL")
  
  (type source
    "A component representing someone speaking.

See NAME")

  (function name
    "Accesses the name of the speaker.

See SOURCE")
  
  (type placeholder
    "A component representing a dynamic piece of text.

See FORM")

  (function form
    "Accesses a Lisp form to be evaluated for the component.

See PLACEHOLDER
See CONDITIONAL-PART
See SETF
See EVAL")
  
  (type emote
    "A component representing an expression of the speaking character.

See EMOTE (function)")

  (function emote
    "Accesses the name describing the expression of the character.

See EMOTE (type)")
  
  (type conditional-part
    "A component representing an inline conditional.

See FORM
See CHOICES")

  (function choices
    "Accesses a vector of choices for the conditional.

Each entry in the vector is a vector of child components.

See CONDITIONAL-PART")
  
  (type fake-instruction
    "A component for instructions that do not cause changes in the markless document.")
  
  (type go
    "Instruction to jump to a specific component.

See ORG.SHIRAKUMO.MARKLESS.COMPONENTS:TARGET")
  
  (type speed
    "Instruction to change the letter scroll speed.

See SPEED (function)")

  (function speed
    "Accesses the speed at which the text should scroll, relative to base speed.

See SPEED (type)")
  
  (type camera
    "Instruction to cause a camera action.

See ACTION
See ARGUMENTS")

  (function action
    "Accesses the action the camera should perform.

Standard actions are:
  - :PAN
  - :ROLL
  - :PITCH
  - :YAW
  - :JUMP
  - :SHAKE
  - :ZOOM

See CAMERA")

  (function arguments
    "Accesses the list of arguments for the camera action.

See CAMERA")
  
  (type move
    "Instruction to move a character to another position.

See ENTITY
See TARGET")

  (function entity
    "Accesses a designator for the entity to move.

See MOVE")
  
  (type setf
    "Instruction to set a place.

See PLACE
See FORM")

  (function place
    "Accesses a form describing the place to set.")
  
  (type eval
    "Instruction to evaluate a piece of Lisp code.

See FORM"))

(in-package #:org.shirakumo.fraf.kandria.dialogue.syntax)

(docs:define-docs
  (type parser
    "Parser class customised to use the correct set of directives and instructions.

See ORG.SHIRAKUMO.MARKLESS:PARSER")

  (type jump
    "Directive representing a jump to another label.

Syntax: \"< label\"")

  (type label
    "Directive representing a label.

Syntax: \"> label\"")

  (type conditional
    "Directive for a conditional block.

Syntax: \"? form\"

Following lines should be either \"| \" for a conditional body or
\"|? form\" for a branch condition, or \"|?\" for an otherwise
branch.")

  (type source
    "Directive for a speaking source.

Syntax: \"~ source\"")

  (type placeholder
    "Directive for a dynamic piece of text.

Syntax: \"{form}\"")

  (type emote
    "Directive for the expression of the speaking character.

Syntax: \"(:emote)\"")

  (type part-separator
    "Directive for the separator of a part in a compound directive.

Syntax: \"|\"")

  (type conditional-part
    "Directive for an inline conditional.

Syntax: \"[form if-clause | else-clause ]\""))

(in-package #:org.shirakumo.fraf.kandria.dialogue)

;;; instructions.lisp
(docs:define-docs
  (type instruction
    "Base class for a dialogue instruction.

See INDEX
See LABEL")
  
  (function index
    "Accesses the index at which this instruction occurs in the sequence.

See INSTRUCTION")
  
  (function label
    "Accesses the label the instruction is associated with, if any.

See INSTRUCTION")
  
  (type noop
    "A no-operation instruction. Does nothing.

See INSTRUCTION")
  
  (type source
    "An instruction representing a change in the speaking source.

See NAME
See INSTRUCTION")
  
  (function name
    "Accesses the name designator the instruction relates to.

See SOURCE")
  
  (type jump
    "An instruction that jumps to another instruction index.

See TARGET
See INSTRUCTION")
  
  (function target
    "Accesses the target of the instruction.

See JUMP
See INSTRUCTION
See TARGET-REQUEST")
  
  (type conditional
    "An instruction that represents a chain of branches, similar to COND.

See CLAUSES
See INSTRUCTION")
  
  (function clauses
    "Accesses the list of clauses of the conditional instruction.

Each entry in the clause list is a cons composed out of a test
function and a jump target.

See CONDITIONAL")
  
  (type dispatch
    "An instruction that represents an if/else dispatch.

See FUNC
See TARGETS")
  
  (function func
    "Accesses the function associated with the instruction.

See DISPATCH
See PLACEHOLDER
See EVAL")
  
  (function targets
    "Accesses the list of targets to jump to depending on the test function.

See DISPATCH")
  
  (type emote
    "An instruction representing a change in expression for the speaker.

See EMOTE (function)
See INSTRUCTION")
  
  (function emote
    "Accesses the designator of the expression that should be displayed.

See EMOTE (type)")
  
  (type pause
    "An instruction representing a pause in speech.

See DURATION
See INSTRUCTION")
  
  (function duration
    "Accesses the duration of the pause (in seconds).

See PAUSE")
  
  (type placeholder
    "An instruction representing a dynamic piece of text.

See FUNC
See INSTRUCTION")
  
  (type choose
    "An instruction representing a request to make the user choose an
    option.

See INSTRUCTION")
  
  (type commit-choice
    "An instruction to commit the current text buffer as a choice.

See JUMP")
  
  (type confirm
    "An instruction to prompt the user to confirm.

See INSTRUCTION")
  
  (type begin-mark
    "An instruction to mark the beginning of a piece of text markup.

See MARKUP
See INSTRUCTION")
  
  (function markup
    "Accesses the identifier for the markup.

See TEXT-REQUEST
See BEGIN-MARK")
  
  (type end-mark
    "An instruction to mark the end of the most recent markup section.

See BEGIN-MARK
See INSTRUCTION")
  
  (type clear
    "An instruction to clear the text.

See INSTRUCTION")
  
  (type text
    "An instruction to output a piece of text.

See TEXT (function)
See INSTRUCTION")
  
  (function text
    "Accesses the text to be output

See TEXT-REQUEST
See TEXT (type)")
  
  (type eval
  "An instruction to execute a Lisp function.

See FUNC
See INSTRUCTION"))


;;; compiler.lisp
(docs:define-docs
  (variable *root*
    "Variable bound to the root of the document for quick access to the label table.

Only bound during compilation.")
  
  (function parse
    "Parses input to a markless component tree.

See ORG.SHIRAKUMO.MARKLESS:PARSE
See ORG.SHIRAKUMO.FRAF.KANDRIA.DIALOGUE.SYNTAX:PARSER")
  
  (function compile
    "Compiles the given input to an assembly.

Unless the input is a component, it is first passed to PARSE before
being compiled.

Note that this function only performs direct compilation to
instructions. Typically this is not sufficient for execution, as jumps
may need to be resolved in an extra optimisation pass.

See ASSEMBLY
See PARSE
See COMPILE*
See WALK")
  
  (function disassemble
    "Prints the assembly in a more readable fashion to help with debugging.

Unless the input is an assembly or an instruction, it is first passed
to COMPILE* before being disassembled.

See ASSEMBLY
See COMPILE*")
  
  (type assembly
    "A class representing a set of instructions ready to be executed.

See INSTRUCTIONS
See NEXT-INDEX
See EMIT
See WALK
See DISASSEMBLE
See RUN-PASS
See RUN")
  
  (function instructions
    "Accesses the vector of instructions of the assembly.

See INSTRUCTION
See ASSEMBLY")
  
  (function next-index
    "Returns the next instruction index to use.

See ASSEMBLY")
  
  (function emit
    "Emits an instruction into the assembly.

This will assign the instruction index and add it to the vector of
instructions in the assembly.

See INSTRUCTION
See ASSEMBLY")
  
  (function walk
    "Walks the AST to emit instructions into the assembly.

This function should have methods for every supported component type
to handle it and compile it into a set of instructions.

See EMIT
See ASSEMBLY
See INSTRUCTION
See ORG.SHIRAKUMO.MARKLESS.COMPONENTS:COMPONENT")
  
  (function define-simple-walker
    "Shorthand macro to define a walker method that emits a single instruction.

See WALK")
  
  (function define-markup-walker
    "Shorthand macro to define a walker method for markup components.

See WALK")
  
  (function resolved-target
    "Resolves the component's target to an actual component in the document tree.

Signals an error if the target cannot be resolved to a target
component.

See ORG.SHIRAKUMO.MARKLESS.COMPONENTS:TARGET
See ORG.SHIRAKUMO.MARKLESS.COMPONENTS:LABEL"))


;;; optimizers.lisp
(docs:define-docs
 (variable *optimization-passes*
    "Variable containing a list of optimisation passes to run by default.

See OPTIMIZE-INSTRUCTIONS")

 (type pass
    "Class representing an optimisation pass.

See RUN-PASS
See OPTIMIZE-INSTRUCTIONS
See COMPILE*
See ASSEMBLY")
  
  (function prun-pass
    "Runs the optimisation pass on the assembly.

This modifies the assembly's instructions.

See PASS
See ASSEMBLY")
  
  (function optimize-instructions
    "Run the assembly through known optimisation passes.

Returns the modified assembly.

See *OPTIMIZATION-PASSES*
See RUN-PASS
See ASSEMBLY")
  
  (function compile*
    "Shorthand to compile and optimise.

See COMPILE
See OPTIMIZE-INSTRUCTIONS")
  
  (type jump-resolution-pass
    "Pass to resolve jumps to labels to actual instruction indices.

After this pass all jumps should have their target be an instruction
index.

See LABEL-MAP
See PASS")
  
  (function label-map
    "Accesses the hash table of labels to instructions.

See JUMP-RESOLUTION-PASS
See NOOP-ELIMINATION-PASS")
  
  (type noop-elimination-pass
    "Pass to eliminate all noop instructions

This pass rewrites jump instructions to resolve to proper indices
without the need for noops. After this pass, no noops should remain in
the assembly.

See LABEL-MAP
See PASS"))


;;; vm.lisp
(docs:define-docs
  (type request
    "Base class for all client requests.

A request requires the client to perform some operation before
execution can resume.")
  
  (type input-request
    "Base class for requests that require user input.

See REQUEST")
  
  (type target-request
    "Base class for requests that advance the instruction pointer after completion.

See REQUEST
See TARGET")
  
  (type text-request
    "Base class for requests that carry some text to be output

See TEXT (function)
See MARKUP")
  
  (type choice-request
    "A request that represents a set of choices for the user to choose between.

Each choice in the list of choices has a corresponding instruction
pointer in the list of targets that the VM should resume from after
the request.

See CHOICES
See TARGETS
See INPUT-REQUEST")
  
  (function choices
    "Accesses the list of choices to present to the user.

Each choice is a string of text to display.

See CHOICE-REQUEST")
  
  (function targets
    "Accesses the list of target instruction pointers.

See CHOICE-REQUEST")
  
  (type confirm-request
    "A request to ask the user to confirm before proceeding with execution.

See INPUT-REQUEST
See TARGET-REQUEST
See TEXT-REQUEST")
  
  (type clear-request
    "A request to clear the current text on screen.

See TARGET-REQUEST")
  
  (type emote-request
    "A request to change the expression of the current speaker.

See TEXT-REQUEST
see TARGET-REQUEST")
  
  (type pause-request
    "A request to pause execution for a period of real time.

See TEXT-REQUEST
See TARGET-REQUEST
See DURATION")
  
  (type source-request
    "A request to change the speaker of the dialogue.

See TARGET-REQUEST
See NAME")
  
  (type end-request
    "A request to end the dialogue.

See REQUEST")
  
  (type vm
    "A class to represent the execution state of a dialogue assembly.

In order to execute dialogue you should first compile it to an
assembly, then construct a VM instance and pass the assembly to the VM
via RUN. This will initialise the VM properly. Afterwards you should
call RESUME, which will return a REQUEST instance, informing you of a
necessary action to take. You should then continue calling RESUME with
the new instruction pointer as instructed by the request until an
END-REQUEST is returned.

See REQUEST
See EXECUTE
See SUSPEND
See INSTRUCTIONS
See RUN")
  
  (function execute
    "Executes an instruction in the VM.

You should add methods to this function if you include new instruction
types. Should return the new instruction pointer, typically (1+ ip).
If an instruction requires execution from the client, it should call
SUSPEND with the appropriate request instance.

It is an error to call EXECUTE from outside of the context of a RESUME
call.

See VM
See INSTRUCTION")
    
  (function run
    "Prepare the VM to run an assembly.

This will initialise the VM with the assembly's instructions and reset
its state.

Returns the VM.

See RESET
See VM")
  
  (function reset
    "Resets the VM to its initial state.

Returns the VM.

See VM")
  
  (function resume
    "Resumes execution of the VM.

This will process instructions until a request to the client has to be
made. To do this the VM will continuously call EXECUTE and update the
instruction pointer. An instruction that requires a request should
call SUSPEND to suspend the execution and return from RESUME.

If the assembly runs to completion (the instruction pointer exceeds
the instruction vector), an END-REQUEST is returned.

See VM
See SUSPEND
See EXECUTE")
  
  (function suspend
    "Suspends execution of the VM to make a request to the client.

This function must only be called from EXECUTE.

See RESUME
See EXECUTE"))

