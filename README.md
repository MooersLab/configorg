# Blaine's initialization file for Emacs

## Introduction to Emacs

Emacs is the ultimate configurable text editor (beware: the configuring process can be a rabbit hole that turns into a black hole).
Emacs has highly developed support for editing plain text, LaTeX, asciidoc, markdown, rtf, html, org-mode, and other kinds of text files.
This support includes autocompletion, access to Grammarly for several document types, snippets, and access to several [Language Server Protocols, LSPs](https://microsoft.github.io/language-server-protocol/).
Text editing can be divided into two Eras: before LSPs and after LSPs.
It is central feature of modern Integrated Development Environments (IDEs).
There is also support for managing citations via BibTex and reading PDFs and ebooks inside of Emacs.

Unfortunately, pre-mature configuration of Emacs is a common source of frustration for beginners.
It is best to use the GUI version of Emacs first and uses the pull-down menus to do productive writing in Emacs.
Once you are comfortable doing basic writing and editing tasks, slowly start to configure your Emacs profile. 

The edit-sever package enables you to edit text areas in webpages using Emacs.
Likewise, the atomic-chrome enables doing so via the GhostText plugin for Chrome.
You click on the ghost icon in your browser's toolbar to send the text to Emacs.
You can then edit the text with the full power of Emac's editing features.
The changed text is updated immediately in the text area in the webpage.
This capability works with Overleaf, the website for editing LaTeX documents on the web.
It also works in the code cells of Jupyter notebooks.
I gave a talk about this [topic](https://github.com/MooersLab/DSW22ghosttext) in July 2022.
Atomic-chrome can be configured to enter the latex-mode whenever invoked from Overleaf.

Emacs is also a software integrated development environment (IDE).
It supports syntax highlighting, code snippets, and autocompletion for many programming languages.

Emacs also supports several approaches to literate programming.
One of the most developed approaches is found in org-mode where the `emacs-jupyter` package enables you to tap into your Jupyter Notebook kernels to access scores of programming languages.
You can switch kernels between code blocks inside one org document and thereby do polyglot literate programming.

The package emacs-jupyter package can be hard to configure and use correctly.
Similar capabilities are available from org-babel via ob-jupyter.
Just list `jupyter` last in the list of org-babel languages.
Use `jupyter` for the language in the code block header and then select the appropriate Jupyter kernel to select the language that you want to use.

Emacs was designed to be a software toolkit for building extensions to the base text editor.
These applications are written in with Emacs Lisp or elisp. 
ELisp is a variant of LISP, which stands for list processing.
Elips descended from MacLisp (no relation to Mac computers) in the 1970s and emerged at about the same time as common lisp.
Elisp has been costumized for programming text editors like Emacs.
Most of the the Emacs code base is written in elisp with a small percentage written in C for speed.
The elisp compiler cannot handle parallel processing, so elisp is not suitable as a moden multipurpose programming language.
However, the core Emacs developer and package developers have extensively optimized the performance of elisp.
Although you can run small programs written in elisp outside of Emacs, you may be better off using Common Lisp or Clojure for general programming.

![Figure 1](https://github.com/MooersLab/configorg/blob/main/emacs-learning-curve.jpg)

Emacs is a configurable workspace in addition to being an editor.
You can do most of your computing tasks inside of Emacs.
Emacs is almost an operating system.
You can replicate your Emacs configuration on Windows, Mac, Linux, and BSD to maintain a uniform working environment regardless of the underlying operating system.





## My fling with chemacs

I changed my setup in January 2022.
I switched to using the *chemacs.el* package to swap emacs configurations on the fly.
I set up aliases to commands to use alternate configurations.
For example, I enter the alias *e29r* to fire up emacs29 with the rational-emacs configuration by Dave Wilson.
The *e29b* alias is used to fire up emacs29 with the brave-emacs configuration from the GitHub site of the Emacs configuration for recommended by [[https://github.com/flyingmachine/emacs-for-clojure/][Daniel Higginbotham]], the author of [[https://www.braveclojure.com/][*Clojure for the Brave and True*]].
The *e29m* alias is used to fire up emacs29 with the mar30-emacs configuraton, which is a rebuild of my default configuration using the files pulled from GitHub.
The mar30-emacs configuration is starting without errors and is working better than before.
Some of the prior package configurations have been commented out.
I will fix them when time permits.

The current *init.el* file is configured with the current default Emacs directory as being *~/mar30-emacs*.
You will 
I stored my aliases in the hidden file *.bashAppAliases* in my home directory.
They fire up GNU Emacs with the GUI.
Change the aliases to start Emacs in the terminal by adding the ~-nw~ flag.
I source this file from my *.zshenv* file.:

```bash
alias e29='/Applications/Emacs.app/Contents/MacOS/Emacs'
alias e29b='/Applications/Emacs.app/Contents/MacOS/Emacs --with-profile brave'
alias e29m='/Applications/Emacs.app/Contents/MacOS/Emacs --with-profile mar30'
alias e29r='/Applications/Emacs.app/Contents/MacOS/Emacs --with-profile rational'
```

I surrended the */Users/blaine/.emacs.d* directory to */chemacs.el/*. 
I now store my default configuration in */Users/blaine/.emacs.default* directory, which was starting up with a error at the end of March 2022 that I could not debug.

I store the profiles for the alternate Emacs configurations in *~/.emacs-profiles.el*, which has the following elisp content:

```bash
(("default" . ((user-emacs-directory . "~/.emacs.default")))
 ("brave" . ((user-emacs-directory . "~/.brave-emacs")))
 ("mar30" . ((user-emacs-directory . "~/.mar30-emacs")))
 ("rational" . ((user-emacs-directory . "~/.rational-emacs")))) 
```

I store of my copy of this repository in */Users/blaine/.emacs.default/ghconfig*.
I then made an bash alias called *gitpull* that pulls from the GitHub repo and copies the new version to the directory above.
This copy is the file that Emacs reads.

```bash
gitpull='git pull && cp config.org ../.'
```

I also made an alias to switch to this folder when needed:

```bash
ghcon='cd ~/.emacs.default/ghconfigorg'
```

## Keep it simple

In July 2021, I stream-lined my configuration by removing about half of the context.
I found that moving all of my workflows to Emacs was too big of a step.
I am not quite advanced of an Emacs user to do everything Emacs.

I am falling back to using several of my prior workflows with other software that were working well for me.
For example, I maintain a diary in a Overleaf in LaTeX.
I used the journal feature of orgmode for several months.
I found myself converting the org entries to LaTeX and pasting them into Overleaf everyday.
This was too much extra work.
If it is not broken, do not fix it.

I moved the inventory of my projects and folders from proj.org file to Google Sheets.
I made too many accidental deletions of subtrees in the proj.org file that I was using to track my projects.
I could have solved this problem by just keeping proj.org under version control with git.
I am now using the Google Sheets workbook to look up projects and the tasks.org to work with projects in agenda.
I no longer need proj.org.

I am trying to limit my use Emacs to do the following activities:

- read epub and PDF documents and capturing notes as I read
- editing LaTeX, markdown, and org files with Grammarly running
- literate programming in org
- exploring Clojure with using cider or the simpler *M-x inf-clojure* 
- using Emacs as an IDE to develop code:
    - C++
    - C
    - Clojure
    - Common Lisp
    - csharp
    - fsharp
    - HTML
    - JavaScript
    - Python
    - R
    - scala
    - Wolfram Language
- connecting projects with org-roam
- using ido-mode and dired for directory navigation 
- using Org-ref version 3 to insert citations and to manage BibTeX file 
- access remote computers with tramp
- use org-agenda inbox.org to maintain my TODO list of scheduled and unscheduled items
- use *term* package to run macport updates 
- use org-agenda's task.org file to prioritize and schedule my tasks
- use org-agenda's tickler.org file to remind me of upcoming events
- use org-pomodoro to track the pomodoros finished in the tasks.org file.

Once I have mastered Emacs for the above the activities, I will consider expanding my use to do the following:

- advance my use of org-agenda
- expand my use of other features of org
- use of elfeed to do literature searches
- reading e-mail inside Emacs
- use the time tracking feature with org capture
- intergrate org capture with manual effort tracking
- figure how to generative time reports from org
- develop pipeline from Google Sheets projects to prog.org
- make more regular use of the pomodoro method
- figure out why magit is so great
- master hydra

## Editorial on org-roam 

Org-roam is an exciting project that supports the building of an electronic zettelkastens in Emacs being using org files as the individual files of the card catalog.
A zettelkasten or card catalog is an approach to knowledge management deployed to good effect by the political scientist Dr. Niklas Luhmann just before the personal computer era.
The electronic enables making links between entries and powerful searching.
The paper version may be more laborious to maintain but be more effective at generating new connections as you fumble through the card catalog.
The experiment has yet to be done to establish which approach is most effective.
I suspect that both forms require many hours of usage per day to obtain their benefit.

I have been using (abusing) my zettelkasten by using it as a massive mindmap.
I am a big fan of mindmaps and the *iThoughtsX.app*.
I find mindmaps to be very stimulating and very effective for generating new ideas.

My zettelkasten is a heirarchical tree that organizes my interests and projects.
It could be thought of as a mindmap of mindmaps.
The *org-roam-ui* enables exploration of the tree in the browser.
You can focus in one subtree at a time.
It is very cool.

I think that this tree of trees approach might be my best use of org-roam for me. 
I have not tried building a mindmap of all of my mindmaps iThoughtsX.
I suppect that it would be too unwieldly.

I see the potential of zettelkastens, but no one has done controlled experiments to test whether it really enhances productivity.
Without such experimental data, the zettelkasten movement is running on blind faith.
The same kind criticism can be made of Emacs.



## Skill levels

In the following text, I refer to the following five levels of skill acquisition in the [Dreyfus and Dreyfus model](http://www.dtic.mil/cgi-bin/GetTRDoc?AD=ADA084551&Location=U2&doc=GetTRDoc.pdf).

- novice
- advanced beginner
- competent user
- proficient user
- expert

These levels have been very thoughtfully interpreted by Trey Jackson in terms of [Emacs skills](https://softwareengineering.stackexchange.com/questions/38131/emacs-and-self-reinforcing-performance). 

```bibtex
{@TechReport{Dreyfus1980AFiveStageModelOfTheMentalActivitiesInvolvedInDirectedSkillAcquisition,
  author      = {Dreyfus, Stuart E and Dreyfus, Hubert L},
  title       = {A five-stage model of the mental activities involved in directed skill acquisition},
  institution = {DTIC Document},
  year        = {1980},
  annote      = {The famous Dreyfus and Dreyfus model of expertise. },
}
```


## My learning Emacs spiral

My skill levels with Emacs and Vim are in the advanced beginner to competent user range.
I am not a professional programmer; I am an academic scientist.
I am a competent user of bash, Python, R, LaTeX, and Gnuplot (one of the most badly underappreciated plotting programs available).

I became competent with the basic Vim keybindings before diving into Emacs.
The ability to use Vim keybindings via evil-mode eased adopting Emacs.
However, mastering the Vim key bindings was two weeks of hell.
The Emacs keybindings are easier to pick up if you go slow and easy.
I have stopped using evil-mode and started using the Emacs key bindings. 
I try to use Vim several times a week to keep up my Vim skills.

You can do a lot in your early use of Emacs by using the intuitive pull-down menus.
You can start using Emacs without remembering any key bindings.
Most tutorials start with the key-bindings; they should really start with the pull-down menus.

My study of Emacs has been discontinuous due to the demands of my professional life.
I have to relearn infrequently used commands due to these discontinuities. 
I have made a series of [quizzes](https://github.com/MooersLab/qemacs) to improve my recall of the commands. 

I want to take these quizzes on spaced intervals, but I have lacked the time and energy to do so.
Nonetheless, it is beneficial to take the relevant quiz before using some of the related features in Emacs.
The quiz takes 5-10 minutes and refreshes the recall of the relevant commands.
Taking the quiz is faster and more effective way to refresh your recall of the commands than searching the World Wide Web, which takes much longer than most people will admit.

I also found it less frustrating to start with bare-bones GNU Emacs than to begin with the pre-configured alternatives (e.g., Doom, Spacemacs, SciMax) loaded with advanced features.
Spacemacs might be best suited for advanced Vim users and other professional developers familiar with similar advanced features in IDEs and expect these advanced features.
After I master Emacs Lisp, I plan to study the preconfigured variants for ideas about how to improve my configuration for GNU Emacs.

I have bounced off Emacs several times over the past three years, but I have used Emacs every day for the past twelve months.
I want to make Emacs my primary editor because I can configure it into an almost complete work environment that reduces context switching.
However, building that environment seems to be a perpetual work in progress.
It is the ultimate editor in that there is not one that is more highly configurable.
You will never want to switch to another editor; of course, it may be more efficient to do so for a shortwhile with specialized IDEs for certain kinds of programming tasks.

You can do a lot with base installation of Emacs, but invariably you will be lured into adding packages to extend Emacs.
There are over 5,000 packages available for Emacs. 
Many have overlapping functionality and objectives.
If there are only 2,000 unique objectives, there are 2,000 reasons to use Emacs.
Limitiations on your mental bandwith will constrain you to use about a tenth of what is on offer.

When starting with Emacs, I recommend limiting yourself to one feature that you can use in your daily workflow.
By meeting a need in your life with Emacs, you will start to build a commitment to learning more.
Your needs are unique to you, so you will have to design your own learning spiral.

For example, a good place to start might be using it to write simple AAAreadme.txt or AAAreadme.md files for coding projects.
Once you become comfortable with the basic editing tasks, you can start writing org documents.
Org is a supercharged markdown variant that recognizes LaTeX, so it is easy to overcome the limitations of most markdown variants.
An org file can be exported to a wide variety of document types.
Then you can starting using one of the major modes for writing computer programs or, if you are not a programmer, you might start to dig into using org-agenda to organize your life.

A hard lesson that I keep relearning is not to overdo it by trying to move all of my workflows into Emacs.
Just move one workflow at a time when it makes sense to do so.
The features that get you hooked may not be the ones you anticipate.



## .emacs or init.el or config.org

The emacs initializiation file contains the settings for parameters for various packages and functions.
It is written in Emacs Lisp or elisp.
Emacs has to read these settings to load the plugins or packages that you want to use.
You can use Emacs without a configuration file and the extra capabibilities provided by the packages, but it will be a less powerful experience.

You can store your configuration in an *.emacs* file that resides in the top directory.
Emacs reads this file on startup.
The home directory is a convenient location to access the file quickly for editing.
The hiding of the file by starting the file name with a period is to hinder you from deleting the file by accident.
I keep this file under version control with git.

You can also store your configuration in a init.el file in the *~/.emacs.d* directory.
The format and content are the same as in the *.emacs* file.

Another approach from Derek Taylor is to have some key settings from the package repositories in the `init.el` file 
and then place the remaining settings in a *config.org* file.
The *config.org* file is an org-mode file with the settings in elisp code blocks.
You can annotate the file with explanatory text outside of the code blocks. 
The explanatory text can contain special instructions about installation of the package
or it can highlight important keybindings.
You can add tables and even embed images.

The elisp code in the code blocks is extracted (tangled) into a *config.el* file when Emacs starts up.
The code enabling this magic resides in the *init.el* file.
The *init.el* file must be present with the *config.org* file in the *.emacs.d* directory. 
I put the *config.org* and *init.el* files under version control because I break them occassionally.

My main source of discouragement with Emacs was frequent breaking of my *.emacs* or *init.el* file.
This usually happens after pasting settings copied from someone else's configuration file without fully understanding the settings.
This is a really bad idea for novices, but it is very tempting to do so.

The approach of storing most of the settings in code blocks in the *config.org* file reduces the temptation to copy large blocks of code from someone else's config file.
This in turn dramatically reduced the frequency the breaks and thus reduced my frustration caused by these breaks.


## Advantages of the config.org file

The use of the org file for the configuration has at least four advantages.

First, the settings are in elisp code blocks.
You store comments and notes in the main text outside of the code blocks.

Second, the org-mode file allows the heirarchical organization of the code blocks into sections and subsections.
The sections can be folded while editing the file. 
When all of the sections are folded, the entire document can be visible in one screen window. 

Third, the org file is automatically rendered nicely by GitHub.
The preview on GitHub also renders the org file, so you can check the beautifully rendered version as you edit it.

Fourth, I have an easier time spotting errors in the rendered version of the org file.

## Emacs tangles on startup

On startup, Emacs strips out (tangles) the emacs-lisp code and writes it to a *config.el* file. 
This literate programming process is called *tangling*. 
The *config.el* file is the file that Emacs uses for its configuration. 
The *config.el* file will be written to your Emacs directory, (aka *~/.emacs.d*). 

You still need some settings in your `init.el` file including one that calls *config.org*.
I used a function to do so. 
I obtained this function from Karl Voit. 
This function is suppose to load the code chunks more rapidly. 

I added the DISABLED tag to some code chunks not to load the code to save time. 
My *config.org* file is now over 2700 lines long.
My *config.el* file is about 1000 lines long.
Emacs takes 3-5 seconds to load.


## Instant access to Emacs via the emacsclient

For instant access to Emacs, launch the emacsclient as a daemon and tap into this daemon.
This procedure is outlined in the [documentation](https://www.emacswiki.org/emacs/EmacsClient).
I currently do not use the daemon and just keep Emacs open for days on end.

First add, the following to the `config.org` file:

```elisp
(server-start)
```

Next, start GNU Emacs version 29 in the GUI using                               

```bash
/Applications/Emacs.app/Contents/MacOS/Emacs --daemon 2>&1 < ~/emacsclient.log &
```
Your `config.org` gets tangled at the start of the daemon.
If you edit the `config.org` file, you may need to restart the daemon before your edits can take effect.

I added the following settings to my *.zshrc* file to be able to use the GUI when launching Emacs.
Set the first option in line two to *-t* to run Emacs in the terminal.

```bash
export ALTERNATE_EDITOR=""
export EDITOR="emacsclient -c"  # $EDITOR opens in terminal
export VISUAL="emacsclient -c -a /Applications/Emacs.app/Contents/MacOS/Emacs" # $VISUAL opens in GUI mode
```

I made an alias called ec29 for emacsclient for version 29.

```bash
alias e29c="echo 'Must have lanuched daemon with /Applications/Emacs.app/Contents/MacOS/Emacs --daemon' && emacsclient -c -a /Applications/Emacs.app/Contents/MacOS/Emacs"
```

After sourcing this file containing the alias, enter *e29c &* to open a frame on the running Emacs daemon.
This enables instant access to the GNU Emacs GUI.

When your Emacs session is finished, close the Emacs frame with the command *C-x 5 0*.

To find the daemon, enter in the terminal:

```bash
pgrep -l Emacs
```

To kill the daemon, enter the following command in the terminal:

```bash
pkill Emacs
```

To make the daemon permanent, see the documentation for [platform specific](https://www.emacswiki.org/emacs/EmacsAsDaemon) instructions.

For Mac OSX, make the following file called `gnu.emacs.daemon.plist`: 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> 
 <plist version="1.0">
  <dict> 
    <key>Label</key>
    <string>gnu.emacs.daemon</string>
    <key>ProgramArguments</key>
    <array>
      <string>/Applications/Emacs.app/Contents/MacOS/Emacs</string>
      <string>--daemon</string>
    </array>
   <key>RunAtLoad</key>
   <true/>
   <key>ServiceDescription</key>
   <string>Gnu Emacs Daemon</string>
  </dict>
</plist>
```

Store this file in the following directory:

```bash
~/Library/LaunchAgents
```

Launch the daemon with the following command.

```bash
launchctl load -w ~/Library/LaunchAgents/gnu.emacs.daemon.plist
```

### Server shutdown

Stop the Emacs daemon from within Emacs with `kill-emacs` or `save-buffers-kill-emacs` in Emacs.
A fancier approach that queries the user about saving open buffers is to add the following to the config.org file.

```bash
;; define function to shutdown emacs server instance
(defun server-shutdown ()
  "Save buffers, Quit, and Shutdown (kill) server"
  (interactive)
  (save-some-buffers)
  (kill-emacs)
  )
```
Use it by entering `M-x server-shutdown`.

After all of this trouble, I have to admit that I am not using the server very often. 
It takes some practice to master managing the server properly and it is a bit of a hassle to shut it down and restart between updates to the configuration file.

## Zsh emacs plugin

There is a *emacs* plugin for zsh that I added to my list of *oh-my-zsh* plugins in my *.zshrc*.
I am not sure that it is doing anything.

## Lazy alternative

Another approach is to leave Emacs running until the next restart of your computer.
Some people have had Emacs sessions run for many weeks or even months.

## Further learning resources

### The built-in documentation

Emacs has an enormous amount of documentation available in-line.
Once you develop the habit of using the built-in documentation, it will meet most of your needs.
Enter *C-h ?* to see a list of all of the options in the '*Metahelp buffer*'.
You can waste an enormous amount of time by avoiding the built-in documentation.
After years of using Google to look almost everything, it takes some effort to develop the habit of using the built-in documentation.

**Tip:** Enter `C-h k' and then select a pull-down menu option to open the corresponding documentation in a new buffer.

### elfeed

This feed service contains thoughtful posts of tips that can improve your use of Emacs.
See the `E/elfeed' section of the config.org file.

### IRC channel

IRC == Internet Relay Channel. 
These are popular with Emacs users. 
The conversations appear in Emacs. 
There is a beginners channel.

*ERC* is a popular *IRC* client for Emacs.

### Slack RSE emacs channel (M-x research)

RSE == Research Software Engineer. 
A Research Software Engineer is anyone who writes code in research labs. 
There is an international society.
I joined the British branch before being aware of the US-RSE, which I subsequently jointed.
The M-x research group in the RSE slack channel meets on the first and third Tuesday of every month.
Past presentations are posted [here](https://m-x-research.github.io/).

### Discord System Crafters Server


### Emacs conferences

Since the 2019 conference, the conference was virtual but also global.
Each talk was prerecorded and then transcribed.
Each talk has a webpage with the text of the transcript, a summary of the discussion, and a link to the video.
Most talks were short so they offer a great way to learn what is available in Emacs. 
The transcripts and links provide gateways to deeper learning.
Only videos are available from the 2013 and 2015 conferences.

* [Emacsconf2021](https://emacsconf.org/2021/)
* [Emacsconf2020](https://emacsconf.org/2020/)
* [Emacsconf2019](https://emacsconf.org/2019/)
* [Emacsconf2015](https://emacsconf.org/2015/videos/)
* [Emacsconf2013](https://emacsconf.org/2013/)


### YouTube series
These can be useful for raising your awareness of packages that are not covered in the books below.
However, the videos can be frustrating when the presenter moves too fast over the keybindings that they are using.
In general, the return on investment may be lower than expected as a novice.
Your time is better spent reading the books listed below and the in-line documentation.

My recommendation is to start with Kauffman's tool session.
It will get you going in 2-3 hours.
Then to take your skills to the next level, I recommend the System Crafters series.

* [Kauffman's tool session on Emacs, part 1](https://www.youtube.com/watch?v=HyMCzEwI4cU&t=2857s)
* [Kauffman's tool session on Emacs, part 2](https://www.youtube.com/watch?v=7ReBnH0MalQ)
* [System Crafters (Dave Wilson)](https://www.youtube.com/c/SystemCrafters)
* [System Crafters on Github (for better list of links to videos)](https://github.com/daviwil/emacs-from-scratch)
* [Protesilaos (a.k.a Prot) Stavrou: Emacs mindset and Unix philosophy](https://www.youtube.com/watch?v=qTncc2lI6OI)
* [Moral lessons from switching to Emacs](https://www.youtube.com/watch?v=gwT5PoXrLVs)
* [Protesilaos Stavrou Playlist](https://www.youtube.com/c/ProtesilaosStavrou/videos?view=0&sort=dd&shelf_id=0)
* [Andrew Tropin](https://www.youtube.com/channel/UCuj_loxODrOPxSsXDfJmpng)
* [Xah Lee](https://www.youtube.com/channel/UCXEJNKH9I4xsoyUNN3IL96)
* [Sacha Chua](https://www.youtube.com/channel/UClT2UAbC6j7TqOWurVhkuHQ)
* [Emacs Elements by Raoul Comninos](https://www.youtube.com/channel/UCe5excZqMeG1CIW-YhMTCEQ)
* [Emacs: fuzzy find files (fzf, ripgrep, Ivy+Counsel)](https://www.youtube.com/watch?v=IDkx48JwDco)
* [An Ivy, Swiper, & Counsel tutorial for Emacs Noobs](https://www.youtube.com/watch?v=AaUlOH4GTCs&t=876s)
* [Mike Zamansky: Using Emacs Series 75 episodes from a computer science professor](https://cestlaz.github.io/stories/emacs/)
* [Using OrgMode to organize your life, Rainer König, 40 short videos](https://www.youtube.com/watch?v=sQS06Qjnkcc&list=PLVtKhBrRV_ZkPnBtt_TD1Cs9PJlU0IIdE) These are in small bits and are highly accessible.



### Websites

* [Prot's superduper config.org file](https://gitlab.com/protesilaos/dotfiles/-/blob/master/emacs/.emacs.d/prot-emacs.org)
* [zsh Emacs plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/emacs)
* [Getting Things Done with Org-mode](https://lucidmanager.org/productivity/getting-things-done-with-emacs/)
* [Org-Mode](http://doc.norang.ca/org-mode.html)
* [Customize zsh](https://brandon.azbill.dev/how-to-customize-your-zsh-terminal)


### GTD in org-mode

* [Org Mode - Organize Your Life In Plain Text!](http://doc.norang.ca/org-mode.html)
* [Orgmode for GTD, Nicolas Petton](https://emacs.cafe/emacs/orgmode/gtd/2017/06/30/orgmode-gtd.html)


### Books

Perhaps because of the self-documenting nature of Emacs, there are not many books about Emacs.
In contrast, there are three times as many books about Clojure, a language with a smaller user base and a third of the lifespan.

Anyways, several of the books listed below are available in electronic form inside Emacs.
The initial banner package will take you to this documentation as will the *C-h ?*.

While traveling up the Emacs learning spiral, I would read these books in the following order. 


#### [Harley Hahn's Emacs Field Guide](http://www.harley.com/emacs/) 

The author recommends reading his book before taking the in-line Emacs tutorial. 
Emacs greybeards differ in opinion on this matter.

Nonetheless, Hahn wrote this book for people with no experience with computing. 
Most graduate students in the biological sciences (outside of bioinformatics and computational biology) would benefit from reading the first several chapters to understand their computers better.

The author has written several technical books about Unix-like operating systems and is an excellent writer. 
Skip this book if you are already a competent user of Emacs.

#### [Learning GNU Emacs, 3rd edition, 2004](https://www.oreilly.com/library/view/learning-gnu-emacs/0596006489/) 

A team of five authors wrote this book. 
The first edition appeared in 1991, so the authors had over a decade to improve the text. 
I think that it is well written.
The authors strove to make the book accessible. 

Nonetheless, I suspect that readers should have some experience with Emacs.
If you are a novice user, internalize the content of chapters 1 and 2 as recommended by the authors. 
If you struggle with the first two chapters, read the above book by Hahn.

*Learning GNU Emacs* will move advanced beginners to the competent-user level despite lacking coverage of some currently popular packages. 
The book is 509 pages; nonetheless, the content is not too lengthy or deep.

Even though I have been using Emacs off and on for three years, I first learned about bookmarks from this book. 
Bookmarks combined with the recent dashboard package make a fast way to resume unfinished work. 
This book is useful for filling holes in your knowledge that are bound to exist if you have neglected to read the official documentation.

The third edition of the book was published before Git and Org became widely used, so the version control and outline-mode chapters are outdated. 
Of course, it also does not cover the Language Server Protocols (LSPs) that empower modern autocompletion. 
LSPs are the most beneficial advance in text editors in the past decade. 

Although it is almost two decades old, more the 95% of the commands in the book still work. 
After mastering the content of this book, you will understand most of the features of Emacs, and you will be well-prepared to master more advanced topics. 
I recommend reading it as a second book because only chapters 1 and 2 overlap with Hahn's book.


#### [Org Mode Compact Guide, version 9.5, 2021, The Org Mode Developers](https://orgmode.org/guide/) 

Org-mode is a significant draw to Emacs for non-programmers and programmers alike. 
Org has many features, some of which appeal to different audiences.

Org-mode has come to dominate the Emacs over the past decade, so it is easy to forget that you can be productive in Emacs without ever using Org. 
In a sense, you can view Org as a fork on the Emacs learning spiral.

This guide is a concise introduction to the essentials of Org-Mode.
It is 29 pages long.


#### [Org Mode Manual, on-line version 9.5, 2021, The Org Mode Developers](https://orgmode.org/manual/) 

This manual is more readable than it appears from its cover. 
Nonetheless, Org still needs a more accessible book for beginners.

#### [GNU EMacs Manual, 19th Edition, 2021, Stallman et al.](https://www.gnu.org/software/emacs/manual/emacs.html) 

This manual is readable.
Its content is similar to that of Cameron et al., but it is current.
The book is not illustrated and does not cover the pull-down menus.
The authors deemed these to be self-explanatory.
I recommend reading it after reading Cameron et al.

#### [Mastering Emacs, 2nd Edition, 2020, Micky Petersen](https://www.masteringemacs.org/)

Read this book if you are a frustrated or impatient advanced beginner who cannot get traction with the last two books. 
The author presents his approach to mastering Emacs without using much of the official documentation. 
Also, read this book to learn about the features of popular packages that make Emacs competitive with Microsoft's rapidly advancing Visual Studio Code editor. 
You will eventually have to return to the last two books to fill holes in your knowledge. 
The author has almost two decades of experience in Emacs.

#### [An Introduction to Programming in Emacs Lisp by Robert Chassell](https://www.gnu.org/software/emacs/manual/eintr.html) 

This book is a must-read, unless you are already a master of Emacs Lisp. 
Eventually, you have to learn Emacs Lisp to understand the code in your Emacs configuration file. 
Fortunately, that is not as hard to do as you may think because the author wrote this book for non-programmers.

Emacs Lisp is a fine first programming language to learn because you can write executable code in only one line, unlike most other programming languages. 
In addition, you can enter *C-j* to the right of the code in any Emacs buffer, and Emacs returns the result on the line below.
You can save the buffer to a file on your hard drive.
In other words, you can execute the code examples from the book interactively and retain a copy of your work in a document for later reference.
This interactive feature of elisp invites exploring what the code can do beyond the examples in the book.

Alternatively, you can place the cursor after the closing parenthesis of an elisp expression and enter *C-x C-e* to execute the code.
This is a great way to test new code for the configuration file without restarting Emacs. 
This interactivity is a blast!

You might find the book too slow and tedious if you are already a Lisp programmer. 
If not but you are a programmer, do not try to read the book without working through the code in an open session of Emacs. 
You will get bored by page 50 and abandon reading the rest of the book if you do.

This book was first released in 1991 and has been updated with most updates of Emacs. 
It was last updated in 2021 for Emacs 27.2. 
This is one of the best-written computer books that I have encountered. 
It is wonderful that it is available for free.

#### [Writing GNU Emacs Extensions by Robert Glickstein, 1997, O'Reilly & Associates](https://www.oreilly.com/library/view/writing-gnu-emacs/9781449395056/) 

This book assumes more prior knowledge of Emacs than the book by Chassell. 
It is accessible to advanced beginners with Emacs. 
It aims to prepare you to write a minor mode in Emacs Lisp. 
Although the book is a quarter-century old, most of the code still works. 
I recommend reading it after completing the book by Chassell.

#### [Hacking your way around in Emacs by Marcin Borkowski](https://leanpub.com/hacking-your-way-emacs/)

This is a self-published book for intermediate users of Emacs Lisp.
The first chapter is free. 
The book has three chapters.

#### [GNU Emacs Lisp Reference Manual by Bill Lewis et al.](https://www.gnu.org/software/emacs/manual/eintr.html) 

This book is a reference manual, so it is a slow read. 
It is an excellent supplemental source while reading the book by Chassell. 
Competent users who want to become proficient users need to read this book.

