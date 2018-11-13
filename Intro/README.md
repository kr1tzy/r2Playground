# Introduction

### Overview
* Introductory slides under resources
* Crackme challenges are in the ./bin directory
* Crackme0x01 walkthrough
* Crackme0x02 walkthrough

#### Crackme0x01
* Before anything i symlinked the binary into my local folder in case I want to extract any information from it and keep it on my machine. 
	* ``cd Intro/local && ln -s ../bin/crackme0x01 .``
* When I approach an unknown binary I generally try to gather as much information as I can at first. This is where rabin2 comes into play.
* Running the command ``rabin2 -I crackme0x01`` reveals good info about the binary.
	* We know it's an x86 elf, 7499 byte size, written in C, little endian, and have several security precautions turned off like the canary.
* Open the crackme0x01 file with radare2 ``r2 -A crackme0x01`` 
	* The -A indicates analysis upon opening. Same as running ``aaa`` after opening it. This is generally frowned upon but the binary is only 7499 bytes.	
* I want to see what functions are in this binary so i run ``afl``
* It looks like main is the only interesting function so I seek there with ``s main``
* A quick ``pdf`` prints the disassembly for this function and it's clear it's simple and where all the logic resides.
* I decompile the function to make it even clearer. ``pdd``
* Apparently the only check is to make sure it's equal to hex 0x149a 
* Obviously this isn't what's it's wanting exactly so I utilize the r2rax core to evaluate 0x149a as an integer with ``? 0x149a``
* The integer form is 5274
* Winner winner chicken dinner.

#### Crackme0x02
* Similar procedure to before, symlink the binary into the local folder and run ``rabin2 -I crackme0x02``
* It basically reveals identical information, even the size. It is in fact a different binary though.
* Main looks like the only good spot to start again (use ``afl``)
* So, seek to main and ``pdf``. This again reveals 1 check for the password but the evaluation of the value that it's getting compared to is statically calculated before hand so we have to find this out.
* I went into the visual graph mode ``VV`` to peruse around and decided to go in and rename some variables.
* Exiting visual mode ``q`` and simple decompilation ``pdd`` reveals the same thing we just saw just in more of a C like syntax.
* There are 4 variables declared up top but it looks like only 3 of them are used. I'll name them a,b, and c. 
	* afvn a local_ch
	* afvn b local_8h
	* afvn c local_4h 
* I'll add comments for what I understand by entering visual mode ``V``, using the cursor ``c``, scrolling to the first byte of whatever line I want to leave a comment on with Vim controls ``hjkl``. Once positioned use ``;`` and enter the comment.
* We have 2 options here, we can either calculate the static value, or nop out the jne. For completeness, I'll explain both.
* Everything up to and including the scanf is printing the intro text and storing the value of our input into c.
* For the static value, I'll first attach radare to it in debug mode with ``r2 -Ad ./crackme0x02``. 
* Instead of calculating the value by hand, i'll simply add a breakpoint right after the value is assigned to eax ``db 0x804844b`` for the check and run it w/ ``dc`` and then output the registers with ``dr``.
* Our value is in eax ``0x00052b24``.
* To get the correct integer value, again run r2rax with ``? 0x52b24`` and we have what we want. 
* Winner winner chicken dinner #1.
* To NOP out the jne, lets reopen it in debug mode (if already in debugging instance run ``ood``), otherwise, start it with ``r2 -Ad ./crackme0x02``.
* ``s main`` and find the jne instruction (``0x08048451``). Enter visual mode, switch to disassembly view, and use the cursor to hover over the bytes and enter ``A`` followed by ``NOP; NOP`` and save the changes.
* Exit visual mode and continue with ``dc``.
* Enter any password and you should get a winner winner chicken dinner.

#### Crackme walkthroughs will be added

#### Resources
* https://docs.google.com/presentation/d/1_eSJX43HtyyBtgN9yW7GI3s9JP9QMnaNHs3H6468kSQ/edit?usp=sharing
* http://security.cs.rpi.edu/courses/binexp-spring2015/
* https://moveax.me/
