%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DBIS Template
% PhD Thesis
% 2018, Ivan Giangreco
%
% Based on the style by the DBIS group and the template used in the PhD thesis
% of Thomas Meyer (CN group)
%
%
% You may find a manual on the memoir package at 
% http://mirrors.ctan.org/macros/latex/contrib/memoir/memman.pdf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{thesis}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Option handling
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newif\ifdrft\drftfalse % use draft modus
\DeclareOption{draft}{\drfttrue} % show draft notes
\DeclareOption{phddraft}{\drfttrue} % alias

\newif\ifendnotes\endnotesfalse
\DeclareOption{endnotes}{\endnotestrue} % enable endnotes

\newif\iftodonotes\todonotesfalse % use todonotes package
\DeclareOption{todonotes}{\todonotestrue} % enable todonotes

\newif\iflibertine\libertinefalse % use libertine font
\DeclareOption{libertine}{\libertinetrue}

\newif\ifmedievalnumerals\medievalnumeralsfalse % use medieval numerals (https://en.wikipedia.org/wiki/Text_figures, https://de.wikipedia.org/wiki/Medi%C3%A4valziffer)
\DeclareOption{medievalnumerals}{\medievalnumeralstrue}

\newif\ifebook\ebookfalse % ready for print by default
\DeclareOption{ebook}{\ebooktrue} % use ebook modus; add colored hyperlinks

\newif\ifedoc\edocfalse % show edoc note (has to be put on online version)
\newif\iflogo\logofalse % Lukas: I was informed by the Dekant that I have to remove the logo also in the printed version!
\DeclareOption{edoc}{\edoctrue\logofalse}

\newif\ifcclicense\cclicensefalse % use CC license
\DeclareOption{cclicense}{\cclicensetrue}

\DeclareOption{final}{\drftfalse\todonotesfalse} % hide draft notes, disable todonotes


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Base Configuration
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% given this template is based on memoir, see: 
%   http://texdoc.net/texmf-dist/doc/latex/memoir/memman.pdf 
% for more information
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{memoir}}
\ProcessOptions\relax
\LoadClass{memoir}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Basic Packages
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[]{xpatch}

\RequirePackage[]{graphicx}
\RequirePackage[]{graphbox}

\RequirePackage[UKenglish,USenglish,ngerman]{babel}

\RequirePackage[en-GB]{datetime2}
\DTMlangsetup[en-GB]{ord=raise}
\RequirePackage[UKenglish,ngerman]{isodate}

\RequirePackage[]{hyphenat}
\RequirePackage[shortcuts]{extdash}

\RequirePackage[]{import}

\RequirePackage[utf8]{inputenc}
\RequirePackage[OT2,T1]{fontenc}
\newcommand\textcyr[1]{{\fontencoding{OT2}\fontfamily{wncyr}\selectfont #1}}

\RequirePackage[]{letltxmacro}

\RequirePackage[]{alphalph} % translates number to letter

\RequirePackage[]{morewrites} % solves the error  "No room for a new \write"

\RequirePackage[]{ccicons} % supports CC license icons


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Bibliography
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[backend=bibtex,style=trad-alpha,citestyle=trad-alpha,doi=true,url=false,maxbibnames=100,maxcitenames=3,mincitenames=3,sorting=nyt,eprint=false]{biblatex}
% if you wish to use biber, change "backend=bibtex" to biber and add the following file for replacing parts of the entries
%\RequirePackage[backend=biber,style=trad-alpha,citestyle=trad-alpha,doi=true,url=true,isbn=true,eprint=false,urldate=long,date=long,maxbibnames=100,maxcitenames=3,mincitenames=3,sorting=nyt,sortlocale=en-GB]{biblatex}
%\RequirePackage[]{thesisbiber}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Page Layout
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% margins
\setlrmarginsandblock{35mm}{25mm}{*}
\setulmarginsandblock{30mm}{30mm}{*}
\checkandfixthelayout

% ruler thicknesses
\newlength{\rulethickness}
\setlength{\rulethickness}{0.4ex}

\newlength{\boldrulethickness}
\setlength{\boldrulethickness}{0.25ex}

\newlength{\finerulethickness}
\setlength{\finerulethickness}{0.1ex}

\flushbottom

% Prevent page breaks in footnotes (https://texwelt.de/wissen/fragen/2421/wie-kann-ich-verhindern-dass-funoten-auf-zwei-seiten-verteilt-ausgegeben-werden)
\interfootnotelinepenalty=10000


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Colors
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[table,x11names,svgnames,dvipsnames]{xcolor}
\RequirePackage[]{tikz}
\RequirePackage[]{tikz-3dplot}

\RequirePackage[]{thesiscolors}

\ifebook
  \colorlet{refcolor}{unired} % color of references in ebook mode
\else
  \colorlet{refcolor}{black}
\fi


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Fonts
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\iflibertine % with libertine option, template uses Libertine font (see ACM template)
  \RequirePackage[]{libertine}
\else % otherwise uses Helvetica and Palatino
  %\RequirePackage[osf,sc]{mathpazo} %otherwise uses Helvetica and Palatino
  \RequirePackage[sc]{mathpazo} % LUKAS: Deactivated Mediävalziffern (https://de.wikipedia.org/wiki/Medi%C3%A4valziffer) by removing osf
  \RequirePackage[]{helvet}
    
  \ifx\textsw\undefined
    \newcommand{\textsw}{\textit}   % Palatino has no swash shape, use italics instead.
  \else
    \renewcommand{\textsw}{\textit}
  \fi
  
  \ifx\swshape\undefined
    \newcommand{\swshape}{\itshape}
  \else
    \renewcommand{\swshape}{\itshape}
  \fi

  \ifx\textssc\undefined
    \newcommand{\textssc}{\textsc} % Palatino has no small caps spaced shape, use small caps instead.
  \else
    \renewcommand{\textssc}{\textsc}
  \fi
\fi

% Possibly specify fonts manually (see also https://www.tug.org/TUGboat/tb27-2/tb87owens.pdf). Alternatively, you may use XeLaTeX.
% \RequirePackage[]{Nitti}
% \RequirePackage[]{MinionPro}
% \RequirePackage[]{MnSymbol}
% \RequirePackage[]{FoundrySterling}
% \DeclareTextFontCommand{\textbf}{\fontseries{db}\selectfont}
% \DeclareTextFontCommand{\mathbf}{\fontseries{b}\selectfont}

\newcommand{\strongemph}[1]{{\bfseries #1}} % bold emphasis


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Versioning
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if you are using a versioning tool, the version is shown in the footer when using the draft option

% git
% requires the following content in .git\hooks\post-{commit,checkout,merge} (three files)
%post-{commit,checkout,merge} START
%#!/bin/sh
%# Copyright 2015 Brent Longborough
%# Part of gitinfo2 package Version 2
%# Release 2.0.7 2015-11-22
%# Please read gitinfo2.pdf for licencing and other details
%# -----------------------------------------------------
%# Post-{commit,checkout,merge} hook for the gitinfo2 package
%#
%# Get the first tag found in the history from the current HEAD
%FIRSTTAG=$(git describe --tags --always --dirty='-*' 2>/dev/null)
%# Get the first tag in history that looks like a Release
%RELTAG=$(git describe --tags --long --always --dirty='-*' --match '[0-9]*.*' 2>/dev/null)
%# Hoover up the metadata
%git --no-pager log -1 --date=short --decorate=short \
%  --pretty=format:"\usepackage[%
%    shash={%h},
%    lhash={%H},
%    authname={%an},
%    authemail={%ae},
%    authsdate={%ad},
%    authidate={%ai},
%    authudate={%at},
%    commname={%cn},
%    commemail={%ce},
%    commsdate={%cd},
%    commidate={%ci},
%    commudate={%ct},
%    refnames={%d},
%    firsttagdescribe={$FIRSTTAG},
%    reltag={$RELTAG}
%  ]{gitexinfo}" HEAD > .git/gitHeadInfo.gin
%post-{commit,checkout,merge} END
%\RequirePackage[]{gitinfo2}
%\newcommand{\draftnote}{\texttt{DRAFT~-~\gitCommitterDate ~-~(rev.~\gitAbbrevHash, branch: \gitBranch)}}

% Mercurial
% requires running pdflatex with -shell-escape
%\immediate\write18{hg parent -v --template "{date(date, '\@percentchar d.\@percentchar m.\@percentchar Y \@percentchar H:\@percentchar M:\@percentchar S')} (rev. {rev}:{node|short})"> hgInfo.tex}
%\newcommand{\draftnote}{\texttt{DRAFT~-~\input{hgInfo.tex}}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Page Style
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% definition of chapter style (i.e. large number and text)
\linespread{1.25}

\setsecnumdepth{subsubsection}
\setcounter{secnumdepth}{4}

% definition of part
\renewcommand*{\parttitlefont}{\sffamily\bfseries\LARGE\upshape\selectfont}
\renewcommand*{\partnamefont}{\scshape}
\renewcommand*{\partnumfont}{\scshape}
\setlength{\cftpartnumwidth}{2em} % default is 1.5em (see page 148 in http://mirror.kumi.systems/ctan/macros/latex/contrib/memoir/memman.pdf)

% definition of chapter
\setlength{\beforechapskip}{-30pt}
\setlength{\afterchapskip}{1pt}
\newcommand*{\colorchapnumber}{}
\newcommand*{\fontchapnumber}{\bfseries\sffamily\fontsize{100}{130}\selectfont}
\newcommand*{\fontchaptitle}{\sffamily\bfseries\huge}
\renewcommand*{\afterchapternum}{\nobreak\vskip\midchapskip}
\renewcommand*{\printchaptername}{}
\setlength{\midchapskip}{20pt}
\renewcommand*{\chapternamenum}{}
\renewcommand*{\printchapternonum}{}
\renewcommand*{\printchapternum}{\par\vskip 50pt\raggedright{\colorchapnumber\fontchapnumber\thechapter}\par}
\renewcommand*{\printchaptertitle}[1]{\raggedright\fontchaptitle{#1}\par \vskip 40pt \nobreak}

% definition of section, subsection, etc. style
\setsecheadstyle{\sffamily\fontsize{17pt}{20pt}\bfseries\raggedright}
\setbeforesecskip{-8mm plus-1ex minus-.2ex}
\setaftersecskip{5mm plus.2ex}

\setsubsecheadstyle{\sffamily\fontsize{14pt}{16pt}\bfseries\raggedright}
\setbeforesubsecskip{-6mm plus-.5ex minus -.2ex}
\setaftersubsecskip{3.5mm plus.2ex}

\setsubsubsecheadstyle{\sffamily\fontsize{12pt}{14pt}\bfseries\raggedright}
\setbeforesubsubsecskip{-6mm plus-.5ex minus -.2ex}
\setaftersubsubsecskip{3.5mm plus.2ex}

% header, footer
\nouppercaseheads
\renewcommand{\chaptermark}[1]{\markboth{#1}{}}
\renewcommand{\sectionmark}[1]{\markright{#1}{}}

\makepagestyle{thesis}
\makeevenhead{thesis}{\thepage}{}{\leftmark}
\makeoddhead{thesis}{\leftmark}{}{\thepage}
\makeheadrule{thesis}{\textwidth}{\finerulethickness}
\makeevenfoot{thesis}{}{}{}
\makeoddfoot{thesis}{}{}{}

\ifdrft
  \copypagestyle{draft}{thesis}

  \newcommand{\draftfooter}{\draftnote}

  \makeevenfoot{empty}{}{\draftfooter}{}
  \makeoddfoot{empty}{}{\draftfooter}{}
  \makeevenfoot{draft}{}{\draftfooter}{}
  \makeoddfoot{draft}{}{\draftfooter}{}

  \pagestyle{draft}

  \patchcmd{\@smemmain}{\cleardoublepage}{\clearpage}{}{}
  \patchcmd{\@smemmain}{\cleardoublepage}{\clearpage}{}{}
\else
  \pagestyle{thesis}
\fi

% remove page number from chapter pages containing a quote (https://tex.stackexchange.com/questions/262888/epigraph-on-part-page)
\xpatchcmd{\epigraphhead}
  {\let\@evenfoot}
  {\let\@oddfoot\@empty\let\@evenfoot}
  {}{}

\aliaspagestyle{chapter}{empty}
\aliaspagestyle{part}{empty}

% images
\newlength{\imagesep}
\newlength{\imagewidth}
\setlength{\imagesep}{0.4cm}
\setlength{\imagewidth}{0.5\linewidth minus 2\imagesep}

% fixing figures/tables below footnotes
\feetbelowfloat
\setlength{\footmarkwidth}{5mm}
\setlength{\footmarksep}{0mm}
\setlength{\footparindent}{-20mm}
\footmarkstyle{\textsuperscript{#1}\hfil}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Appendix
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\renewcommand{\appendixpagename}{Appendix}% name of the appendix page
\renewcommand{\appendixtocname}{\appendixpagename}% name of the appendix page in the ToC
\xpatchcmd{\addappheadtotoc}% ToC level of the appendix page
  {\addcontentsline{toc}{chapter}}% replace this command...
  {\addcontentsline{toc}{part}}% ...with this one.
  {}{}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Text adjustments
%% Description, Enumeration, Itemize, Endnote, Epigraph
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% allow for more compact list environments
\RequirePackage[inline]{enumitem}

% description environment
\renewcommand*{\descriptionlabel}[1]{%
  \hspace\labelsep\normalfont\strongemph{#1}%
}

\renewenvironment{description}%
  {\begin{flexlabelled}{descriptionlabel}{0pt}{*}{-1.5em}{1.5em}{0em}}%
  {\end{flexlabelled}}

\renewcommand*{\blockdescriptionlabel}[1]{%
  \normalfont\strongemph{#1}%
}

% itemize environment
\renewcommand*{\labelitemi}{\textendash}
\renewcommand*{\labelitemii}{\textendash}
\renewcommand*{\labelitemiii}{\textendash}
\renewcommand*{\labelitemiv}{\textendash}

% enumerate environment
\renewcommand{\labelenumi}{\strongemph{\theenumi.}}
\renewcommand{\labelenumii}{\strongemph{\theenumii.}}
\renewcommand{\labelenumiii}{\strongemph{\theenumiii.}}
\renewcommand{\labelenumiv}{\strongemph{\theenumiv.}}

% endnotes
\RequirePackage[]{endnotes}
\ifendnotes
  \renewcommand*\makeenmark{\hbox{\textsuperscript{\alphalph{\theenmark}}}}
  \renewcommand\enoteformat{%
    \raggedright
    \leftskip=1.8em
    \makebox[0pt][r]{\alphalph{\theenmark}. \rule{0pt}{\dimexpr\ht\strutbox+\baselineskip}}%
  }
  \renewcommand{\notesname}{}
\else
  \LetLtxMacro{\endnote}{\footnote}
\fi

% epigraphs
\epigraphfontsize{\small\itshape}
\newcommand{\epiquote}[2]{\epigraphhead[70]{\epigraph{\begin{SingleSpace}#1\end{SingleSpace}}{\begin{SingleSpace}--- \textup{#2}\end{SingleSpace}}}}
\setlength{\epigraphrule}{\finerulethickness}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Figures (Step 1)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[]{float}

% figure caption
\loosesubcaptions
\RequirePackage[]{caption}
\RequirePackage[]{subcaption}
\captionsetup[figure]{format=hang,justification=justified,singlelinecheck=false,font={sf,bf,small},labelfont={sf,bf},labelsep=quad,textfont={sf,bf}}
\captionsetup[subfigure]{format=hang,justification=justified,singlelinecheck=false,font={sf,bf,footnotesize},labelfont={sf,bf},labelsep=quad,textfont={sf,bf}}

% special caption commands: these allow to easily specify the caption for TOC, the bold printed caption and a normal printed part for explanation
\newcommand{\captionTB}[2]{\caption[#1]{#2.}}
\newcommand{\captionTBE}[3]{\caption[#1]{#2. \textmd{#3}}}

% adjust figure default
\newcommand{\figuresettings}{\centering}
\LetLtxMacro{\originalfigure}{\figure}
\LetLtxMacro{\originalendfigure}{\endfigure}
\renewenvironment{figure}[1][t]%
  {\originalfigure[#1]% \begin{figure}[ht]
   \figuresettings}%
  {\originalendfigure}% \end{figure}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Tables
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[]{booktabs}
\RequirePackage[]{dcolumn}
\RequirePackage[]{rotating}
\RequirePackage[]{threeparttable}
\RequirePackage[]{tabularx}
\RequirePackage[]{tabulary}
\RequirePackage[]{multirow}
\RequirePackage[]{makecell}
\RequirePackage[]{array}
\RequirePackage[]{ragged2e}

% table caption
\captionsetup[table]{format=hang,justification=justified,singlelinecheck=false,font={sf,bf,small},labelfont={sf,bf},labelsep=quad,textfont={sf,bf}}

% adjust table default
\newcommand{\tablesettings}{\sffamily\footnotesize\renewcommand\arraystretch{1.25}\centering}
\LetLtxMacro{\originaltable}{\table}
\LetLtxMacro{\originalendtable}{\endtable}
\renewenvironment{table}[1][t]%
  {\originaltable[#1]% \begin{table}[ht]
   \tablesettings}%
  {\originalendtable}% \end{table}

% additional column type (allowing to specify width and positioning)
\newcolumntype{P}[1]{>{\RaggedRight\hspace{0pt}}p{#1}}
\newcolumntype{L}[1]{>{\raggedright\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}
\newcolumntype{C}[1]{>{\centering\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}
\newcolumntype{R}[1]{>{\raggedleft\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}

\setlength\heavyrulewidth{\boldrulethickness}
\setlength\lightrulewidth{\finerulethickness}
\setlength\cmidrulewidth{\finerulethickness}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Algorithms
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[chapter]{algorithm}
\RequirePackage[]{algorithmicx}
\RequirePackage[]{algpseudocode}
\RequirePackage[]{tabto}
\RequirePackage[]{listings}

% options
\setverbatimfont{\normalfont\ttfamily\small}

% algorithm caption
\captionsetup[algorithm]{format=hang,justification=justified,singlelinecheck=false,font={sf,bf,small},labelfont={sf,bf},labelsep=quad,textfont={sf,bf}}

% default commands
\newcommand{\InputState}{\Statex \textbf{Input:}\tabto{1.8cm}}
\newcommand{\OutputState}{\Statex \textbf{Output:}\tabto{1.8cm}}
\newcommand{\StateSubseq}{\Statex \tabto{1.8cm}}
\newcommand{\AlgorithmLine}[1][\finerulethickness]{\par\vskip.5\baselineskip\hrule height #1\par\vskip.5\baselineskip}

% adjust thickness of algorithm lines
\renewcommand\fs@ruled{\def\@fs@cfont{\bfseries}\let\@fs@capt\floatc@ruled
  \def\@fs@pre{\hrule height \boldrulethickness depth0pt \kern2pt}%
  \def\@fs@post{\kern2pt\hrule height \boldrulethickness depth0pt \relax}%
  \def\@fs@mid{\kern2pt\hrule height \finerulethickness depth0pt \kern2pt}%
  \let\@fs@iftopcapt\iftrue}

\algrenewcommand\ALG@beginalgorithmic{\footnotesize}

\lstset{breaklines=true,basicstyle=\footnotesize\ttfamily}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Math
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[]{textcomp}
\RequirePackage[]{mathtools}

% bold font face for math symbols (use \bm{...})
%\newcommand\bmmax{10} % increases number of math alphabets

% Hack for "too many math alphabets used in version normal" (https://tex.stackexchange.com/questions/3676/too-many-math-alphabets-error)
\newcommand\hmmax{0}
\newcommand\bmmax{0}

\RequirePackage[]{bm}

\RequirePackage[]{amssymb}
\RequirePackage[]{amsthm}

\iflibertine
  \RequirePackage[libertine]{newtxmath}
\else
  \RequirePackage[]{newtxmath}
\fi


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Definitions, Examples, Theorems, Corollaries, Proofs (Step 1)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[]{thmtools}
\RequirePackage[many]{tcolorbox}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% PDF
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[]{pdfpages}

\RequirePackage[
  % General options
  \ifdrft
    final, % Originally "draft," (disabled draft mode to have working links and correct pagelayout in Acrobat reader)
    pdfpagelayout = TwoColumnLeft, %TwoPageLeft, % To be consistent with TeXstudio, and to make sure that chapters start at the right side (as in final mode)
  \else
    final,
    pdfpagelayout = TwoColumnRight, %TwoPageRight,
  \fi
  unicode,
  % Configuration options
  breaklinks = true,                  % allow link text to break across lines
  % Extension options
  hyperfigures,                       % hyperlink for figure refs
  hyperindex,                         % hyperlink in index
  hyperfootnotes,                     % hyperlink for footnotes
  linktocpage,                        % TOC: page nr. instead of text is link
  colorlinks,                         % color the of links  
  linkcolor = refcolor,
  anchorcolor = refcolor,
  citecolor = black,
  filecolor = refcolor,
  menucolor = refcolor,
  runcolor = refcolor,
  urlcolor = refcolor,
  plainpages = false,
  pdfpagelabels,
  bookmarks,                          % write Acrobat bookmarks to PDF
  bookmarksopen = true,               % open all bookmarks in viewer
  bookmarksopenlevel = 3,             % open up to section
  bookmarksnumbered,                  % include section numbers
  % PDF display and information options
  pdfencoding = auto,
  pdfpagemode = UseNone,              % Originally "UseOutlines" to show bookmarks in viewer
  pdftitle = \thesistitle,
  pdfauthor = \thesisauthor,
  pdfsubject = {PhD\ Thesis},
  pdfstartview = Fit,
  pdfpagelabels
]{hyperref}

\RequirePackage[all]{hypcap} % fixes jumping to figure, not to caption

\RequirePackage[]{bookmark}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Glossary
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% glossary must be loaded after hyperref!!!
\RequirePackage[toc,acronym,nomain,makeindex,nopostdot,section=chapter]{glossaries}

% symbols glossary
\newglossary[slg]{symbols}{sls}{slo}{\glssymbolsgroupname}

% https://latex.org/forum/viewtopic.php?t=4420
\setlength{\glsdescwidth}{0.75\linewidth}

% ungrouped glossary style
\newglossarystyle{thesisglossary}{%
  \setglossarystyle{long}%
  \renewenvironment{theglossary}%
    {\begin{longtable}[l]{@{\kern\listOfIndent}lp{\glsdescwidth}}}%
    {\end{longtable}}%
}

% grouped glossary style
\newglossarystyle{groupedthesisglossary}{%
  \setglossarystyle{long}%
  \renewcommand*{\glsgroupheading}[1]{%
    \\ \textbf{\textsf{\glsgetgrouptitle{##1}}} \\%
  }%
  \renewenvironment{theglossary}%
    {\begin{longtable}[l]{@{\kern\listOfIndent}lp{\glsdescwidth}}}%
    {\end{longtable}}%
}

% dedicated acronyms glossary style
\newglossarystyle{acronymthesisglossary}{%
  \setglossarystyle{long}%
  % https://tex.stackexchange.com/questions/166169/adjust-space-between-acronym-and-glossary-description?rq=1
  \renewenvironment{theglossary}%
    {\begin{longtable}[l]{@{\kern\listOfIndent}p{\dimexpr 2.5cm-\tabcolsep}p{0.8\hsize}}}%
    {\end{longtable}}%
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Index
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[]{makeidx}

% allows to use "see ..." in index
\newcommand\gobbleone[1]{}
\newcommand{\seeonly}[2]{\ (\emph{\seename} #1)}
\newcommand{\seeonlyindex}[2]{\index{#1@#1\protect\gobbleone|seeonly{#2}}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% References
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cleveref must be loaded after hyperref!!!
\RequirePackage[
  %nameinlink, % when you use more than one link in the document at the same time, e.g. \cref{fig:1, fig:2}, remove the nameinlink option from cleveref because otherwise, links are not uniform since the name and the number of fig:1 will point to fig:1, but only the number of fig:2 will point to fig:2.
  capitalize, noabbrev
]{cleveref}

\crefname{figure}{Figure}{Figures}
\Crefname{figure}{Figure}{Figures}

\crefname{subfigure}{Figure}{Figures}
\Crefname{subfigure}{Figure}{Figures}

\crefname{table}{Table}{Tables}
\Crefname{table}{Table}{Tables}

\crefname{part}{Part}{Parts}
\Crefname{part}{Part}{Parts}

\crefname{appendix}{Appendix}{Appendices}
\Crefname{appendix}{Appendix}{Appendices}

\crefname{equation}{Equation}{Equations}
\Crefname{equation}{Equation}{Equations}

\crefname{item}{Item}{Items}
\Crefname{item}{Item}{Items}

\crefname{chapter}{Chapter}{Chapters}
\Crefname{chapter}{Chapter}{Chapters}

\crefname{section}{Section}{Sections}
\Crefname{section}{Section}{Sections}

\crefname{subsection}{Section}{Sections}
\Crefname{subsection}{Section}{Sections}

\crefname{subsubsection}{Section}{Sections}
\Crefname{subsubsection}{Section}{Sections}

\crefname{paragraph}{Paragraph}{Paragraphs}
\Crefname{paragraph}{Paragraph}{Paragraphs}

\crefname{footnote}{Footnote}{Footnotes}
\Crefname{footnote}{Footnote}{Footnotes}

\crefname{algorithm}{Algorithm}{Algorithms}
\Crefname{algorithm}{Algorithm}{Algorithms}

\crefname{tcb@cnt@definition}{Definition}{Definitions}
\Crefname{tcb@cnt@definition}{Definition}{Definitions}

\crefname{tcb@cnt@example}{Example}{Examples}
\Crefname{tcb@cnt@example}{Example}{Examples}

\crefname{tcb@cnt@theorem}{Theorem}{Theorems}
\Crefname{tcb@cnt@theorem}{Theorem}{Theorems}

\crefname{tcb@cnt@proof}{Proof}{Proofs}
\Crefname{tcb@cnt@proof}{Proof}{Proofs}

\crefname{tcb@cnt@corollary}{Corollary}{Corollaries}
\Crefname{tcb@cnt@corollary}{Corollary}{Corollaries}


\newcommand{\myref}[1]{\cref{#1}\mynameref{#1}{\csname r@#1\endcsname}}
\newcommand{\Myref}[1]{\Cref{#1}\mynameref{#1}{\csname r@#1\endcsname}}

\def\mynameref#1#2{%
  \begingroup
    \edef\@mytxt{#2}%
    \edef\@mytst{\expandafter\@thirdoffive\@mytxt}%
    \ifx\@mytst\empty\else
    \space(\nameref{#1})\fi
  \endgroup
}

\LetLtxMacro{\orgautoref}{\autoref}

% \autoref is used inside the sentence
\renewcommand{\autoref}{%
  \def\figureautorefname{Figure}%
  \def\subfigureautorefname{Figure}%
  \def\tableautorefname{Table}%
  \def\partautorefname{Part}%
  \def\appendixautorefname{Appendix}%
  \def\equationautorefname{Equation}%
  \def\itemautorefname{item}%
  \def\chapterautorefname{Chapter}%
  \def\sectionautorefname{Section}%
  \def\subsectionautorefname{Section}%
  \def\subsubsectionautorefname{Section}%
  \def\paragraphautorefname{Paragraph}%
  \def\footnoteautorefname{Footnote}%
  \def\algorithmautorefname{Algorithm}%
  \def\tcb@cnt@definitionautorefname{Definition}%
  \def\tcb@cnt@exampleautorefname{Example}%
  \def\tcb@cnt@theoremautorefname{Theorem}%
  \def\tcb@cnt@proofautorefname{Proof}%
  \def\tcb@cnt@corollaryautorefname{Corollary}%
  \orgautoref%
}

% \autorefs is used inside the sentence for multiple items
\newcommand{\autorefs}{%
  \def\figureautorefname{Figures}%
  \def\subfigureautorefname{Figures}%
  \def\tableautorefname{Tables}%
  \def\partautorefname{Parts}%
  \def\appendixautorefname{Appendices}%
  \def\equationautorefname{\hspace*{-.5ex}}%
  \def\itemautorefname{items}%
  \def\chapterautorefname{Chapters}%
  \def\sectionautorefname{Sections}%
  \def\subsectionautorefname{Sections}%
  \def\subsubsectionautorefname{Sections}%
  \def\paragraphautorefname{Paragraphs}%
  \def\footnoteautorefname{Footnotes}%
  \def\algorithmautorefname{Algorithms}%
  \def\tcb@cnt@definitionautorefname{Definitions}%
  \def\tcb@cnt@exampleautorefname{Examples}%
  \def\tcb@cnt@theoremautorefname{Theorems}%
  \def\tcb@cnt@proofautorefname{Proofs}%
  \def\tcb@cnt@corollaryautorefname{Corollaries}%
  \orgautoref%
}

% \Autoref is for the beginning of the sentence
\renewcommand{\Autoref}{%
  \def\figureautorefname{Figure}%
  \def\subfigureautorefname{Figure}%
  \def\tableautorefname{Table}%
  \def\partautorefname{Part}%
  \def\appendixautorefname{Appendix}%
  \def\equationautorefname{Equation}%
  \def\itemautorefname{Item}%
  \def\chapterautorefname{Chapter}%
  \def\sectionautorefname{Section}%
  \def\subsectionautorefname{Section}%
  \def\subsubsectionautorefname{Section}%
  \def\paragraphautorefname{Paragraph}%
  \def\footnoteautorefname{Footnote}%
  \def\algorithmautorefname{Algorithm}%
  \def\tcb@cnt@definitionautorefname{Definition}%
  \def\tcb@cnt@exampleautorefname{Example}%
  \def\tcb@cnt@theoremautorefname{Theorem}%
  \def\tcb@cnt@proofautorefname{Proof}%
  \def\tcb@cnt@corollaryautorefname{Corollary}%
  \orgautoref%
}

% \Autorefs is for multiple items at the beginning of the sentence
\newcommand{\Autorefs}{%
  \def\figureautorefname{Figures}%
  \def\subfigureautorefname{Figures}%
  \def\tableautorefname{Tables}%
  \def\partautorefname{Parts}%
  \def\appendixautorefname{Appendices}%
  \def\equationautorefname{Equations}%
  \def\itemautorefname{Items}%
  \def\chapterautorefname{Chapters}%
  \def\sectionautorefname{Sections}%
  \def\subsectionautorefname{Sections}%
  \def\subsubsectionautorefname{Sections}%
  \def\paragraphautorefname{Paragraphs}%
  \def\footnoteautorefname{Footnotes}%
  \def\algorithmautorefname{Algorithms}%
  \def\tcb@cnt@definitionautorefname{Definitions}%
  \def\tcb@cnt@exampleautorefname{Examples}%
  \def\tcb@cnt@theoremautorefname{Theorems}%
  \def\tcb@cnt@proofautorefname{Proofs}%
  \def\tcb@cnt@corollaryautorefname{Corollaries}%
  \orgautoref%
}

\newcommand{\autorefpage}[1]{\autoref{#1} on page~\pageref{#1}}
\newcommand{\Autorefpage}[1]{\Autoref{#1} on page~\pageref{#1}}
\newcommand{\eqrefpage}[1]{\eqref{#1} on page~\pageref{#1}}
\newcommand{\refpage}[1]{\ref{#1} on page~\pageref{#1}}

\renewcommand\theHchapter{\thechapter}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Figures (Step 2)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% options
\newsubfloat{figure} % allow subfloats in figure environment (use subbottom[...]{...})
% has to be executed after loading hyperref (https://tex.stackexchange.com/questions/303155/hyperref-destination-with-the-same-identifier-has-been-already-used-dupl)

% parentheses around subfig references
\renewcommand\thesubfigure{(\alph{subfigure})}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Definitions, Examples, Theorems, Corollaries, Proofs (Step 2)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%use with (\begin{definition}...\end{definition})
\newtcbtheorem[auto counter,number within=chapter,list inside=defs]{definition}{Definition}{
  breakable,%
  enhanced jigsaw,% <--- jigsaw
  frame hidden,interior hidden,
  titlerule = \finerulethickness,%
  titlerule style={black},%
  before skip=20pt,%
  after skip=20pt,%
  colback=white,%
  arc=0pt,%
  outer arc=0pt,%
  leftrule=0pt,%
  rightrule=0pt,%
  toprule=\boldrulethickness,
  bottomrule=\boldrulethickness,
  colframe=black,%
  colbacktitle=white,%
  fonttitle=\sffamily\small\bfseries,%
  coltitle=black,%
  separator sign=\quad,%
  left=0pt,%
  right=0pt,%
  borderline south={\boldrulethickness}{0pt}{black},%---- draw line
  borderline north={\boldrulethickness}{0pt}{black},%---- draw line
  % before upper={\parindent15pt}, % indents the paragraphs, as normally in the text
}{def}

%use with (\begin{example}...\end{example})
\newtcbtheorem[auto counter,number within=chapter,list inside=exs]{example}{Example}{
  breakable,%
  enhanced jigsaw,% <--- jigsaw
  frame hidden,interior hidden,
  titlerule = \finerulethickness,%
  titlerule style={black},%
  before skip=20pt,%
  after skip=20pt,%
  colback=white,%
  arc=0pt,%
  outer arc=0pt,%
  leftrule=0pt,%
  rightrule=0pt,%
  toprule=\boldrulethickness,
  bottomrule=\boldrulethickness,
  colframe=black,%
  colbacktitle=white,%
  fonttitle=\sffamily\small\bfseries,%
  coltitle=black,%
  separator sign=\quad,%
  left=0pt,%
  right=0pt,%
  borderline south={\boldrulethickness}{0pt}{black},%---- draw line
  borderline north={\boldrulethickness}{0pt}{black},%---- draw line
  % before upper={\parindent15pt}, % indents the paragraphs, as normally in the text
}{ex}

 %use with (\begin{theorem}...\end{theorem})
\newtcbtheorem[auto counter,number within=chapter,list inside=thms]{theorem}{Theorem}{
  breakable,%
  enhanced jigsaw,% <--- jigsaw
  frame hidden,interior hidden,
  titlerule = \finerulethickness,%
  titlerule style={black},%
  before skip=20pt,%
  after skip=20pt,%
  colback=white,%
  arc=0pt,%
  outer arc=0pt,%
  leftrule=0pt,%
  rightrule=0pt,%
  toprule=\boldrulethickness,
  bottomrule=\boldrulethickness,
  colframe=black,%
  colbacktitle=white,%
  fonttitle=\sffamily\small\bfseries,%
  coltitle=black,%
  separator sign=\quad,%
  left=0pt,%
  right=0pt,%
  borderline south={\boldrulethickness}{0pt}{black},%---- draw line
  borderline north={\boldrulethickness}{0pt}{black},%---- draw line
  % before upper={\parindent15pt}, % indents the paragraphs, as normally in the text
}{thm}

\LetLtxMacro{\proof}{\relax}
\LetLtxMacro{\endproof}{\relax}
%use with (\begin{proof}...\end{proof})
\newtcbtheorem[auto counter,number within=chapter,list inside=pros]{proof}{Proof}{
  breakable,%
  enhanced jigsaw,% <--- jigsaw
  frame hidden,interior hidden,
  titlerule = \finerulethickness,%
  titlerule style={black},%
  before skip=20pt,%
  after skip=20pt,%
  colback=white,%
  arc=0pt,%
  outer arc=0pt,%
  leftrule=0pt,%
  rightrule=0pt,%
  toprule=\boldrulethickness,
  bottomrule=\boldrulethickness,
  colframe=black,%
  colbacktitle=white,%
  fonttitle=\sffamily\small\bfseries,%
  coltitle=black,%
  separator sign=\quad,%
  left=0pt,%
  right=0pt,%
  borderline south={\boldrulethickness}{0pt}{black},%---- draw line
  borderline north={\boldrulethickness}{0pt}{black},%---- draw line
  % before upper={\parindent15pt}, % indents the paragraphs, as normally in the text
}{pro}

%use with (\begin{corollary}...\end{corollary})
\newtcbtheorem[auto counter,number within=chapter,list inside=crlrs]{corollary}{Corollary}{
  breakable,%
  enhanced jigsaw,% <--- jigsaw
  frame hidden,interior hidden,
  titlerule = \finerulethickness,%
  titlerule style={black},%
  before skip=20pt,%
  after skip=20pt,%
  colback=white,%
  arc=0pt,%
  outer arc=0pt,%
  leftrule=0pt,%
  rightrule=0pt,%
  toprule=\boldrulethickness,
  bottomrule=\boldrulethickness,
  colframe=black,%
  colbacktitle=white,%
  fonttitle=\sffamily\small\bfseries,%
  coltitle=black,%
  separator sign=\quad,%
  left=0pt,%
  right=0pt,%
  borderline south={\boldrulethickness}{0pt}{black},%---- draw line
  borderline north={\boldrulethickness}{0pt}{black},%---- draw line
  % before upper={\parindent15pt}, % indents the paragraphs, as normally in the text
}{crlr}

% https://tex.stackexchange.com/questions/187415/tcblistof-book-class-and-vertical-spacing
\xapptocmd{\Hy@org@chapter}{% 
  \addtocontents{defs}{\protect\addvspace{10\p@}}% 
  \addtocontents{exs}{\protect\addvspace{10\p@}}% 
  \addtocontents{thms}{\protect\addvspace{10\p@}}% 
  \addtocontents{pros}{\protect\addvspace{10\p@}}% 
  \addtocontents{crlrs}{\protect\addvspace{10\p@}}%
  \addtocontents{loa}{\protect\addvspace{10\p@}}% 
}{}{}


% Set number width and indentation for all list ofs
\def\listOfNumWidth{11mm}
\def\listOfIndent{0em}

% https://tex.stackexchange.com/questions/73032/memoir-change-numwidth-in-list-of-figures
\setlength{\cftfigurenumwidth}{\listOfNumWidth}
\setlength{\cfttablenumwidth}{\listOfNumWidth}

% https://arthur-schiwon.de/formatierung-von-tabellen-und-abbildungsverzeichnis-mit-latex
\setlength{\cftfigureindent}{\listOfIndent}
\setlength{\cfttableindent}{\listOfIndent}

% Remove indentation in List of Definitions, Examples, Theorems, Proofs, and Corollaries
% See https://ctan.mc1.root.project-creative.net/macros/latex/contrib/memoir/memman.pdf Section 9.1)
\renewcommand*{\l@tcolorbox}{\@dottedtocline{1}{\listOfIndent}{\listOfNumWidth}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% TOC, List of *, Bibliography, Index
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ToC
\LetLtxMacro{\@@latex@@tableofcontents}{\tableofcontents}
\renewcommand{\tableofcontents}{%
  \renewcommand{\contentsname}{Contents} % if you want to redefine the name of the table of contents
  \maxtocdepth{subsubsection} % define here how deep your ToC should go
  \phantomsection
  \pdfbookmark[chapter]{\contentsname}{toc}
  \@@latex@@tableofcontents*%
}

% List of Figures
\LetLtxMacro{\@@latex@@listoffigures}{\listoffigures}
\renewcommand{\listoffigures}{%
  \@@latex@@listoffigures%
}

% List of Tables
\LetLtxMacro{\@@latex@@listoftables}{\listoftables}
\renewcommand{\listoftables}{%
  \@@latex@@listoftables%
}

% List of Definitions
\newcommand{\listofdefinitions}{%
  \phantomsection
  \addcontentsline{toc}{chapter}{List of Definitions}
  \markboth{List of Definitions}{}
  \tcblistof[\chapter*]{defs}{List of Definitions}
}

% List of Theorems
\renewcommand{\listoftheorems}{%
  \phantomsection
  \addcontentsline{toc}{chapter}{List of Theorems}
  \markboth{List of Theorems}{}
  \tcblistof[\chapter*]{thms}{List of Theorems}
}

% List of Corollaries
\newcommand{\listofcorollaries}{%
  \phantomsection
  \addcontentsline{toc}{chapter}{List of Corollaries}
  \markboth{List of Corollaries}{}
  \tcblistof[\chapter*]{crlrs}{List of Corollaries}
}

% List of Proofs
\newcommand{\listofproofs}{%
  \phantomsection
  \addcontentsline{toc}{chapter}{List of Proofs}
  \markboth{List of Proofs}{}
  \tcblistof[\chapter*]{pros}{List of Proofs}
}

% List of Algorithms
\LetLtxMacro{\@@latex@@listofalgorithms}{\listofalgorithms}
\LetLtxMacro{\old@dottedtocline}{\@dottedtocline}
\renewcommand{\@dottedtocline}[5]{\old@dottedtocline{1}{\listOfIndent}{\listOfNumWidth}{#4}{#5}}
\LetLtxMacro{\patched@dottedtocline}{\@dottedtocline}
\LetLtxMacro{\@dottedtocline}{\old@dottedtocline}
\renewcommand{\listofalgorithms}{%
  \phantomsection
  \addcontentsline{toc}{chapter}{List of Algorithms}
  \markboth{List of Algorithms}{}
  % https://tex.stackexchange.com/questions/299832/how-to-remove-the-tab-from-the-listofalgorithms-toa?rq=1
  \LetLtxMacro{\@dottedtocline}{\patched@dottedtocline}
  \@@latex@@listofalgorithms%
  \LetLtxMacro{\@dottedtocline}{\old@dottedtocline}
}

% List of Examples
\newcommand{\listofexamples}{%
  \phantomsection
  \addcontentsline{toc}{chapter}{List of Examples}
  \markboth{List of Examples}{}
  \tcblistof[\chapter*]{exs}{List of Examples}
}

% List of Acronyms
\newcommand{\listofacronyms}{%
  \printglossary[type={acronym},style={acronymthesisglossary},title={List of Acronyms},nonumberlist]
}

% List of Symbols
\newcommand{\listofsymbols}[1][groupedthesisglossary]{%
  \printglossary[type={symbols},style={#1},title={List of Symbols},nonumberlist]
}

% Endnotes
\newcommand{\printendnotes}{%
  \phantomsection
  \addcontentsline{toc}{chapter}{Endnotes}
  \markboth{Endnotes}{}
  \chapter*{Endnotes}
  \theendnotes
}

% Bibliography
\LetLtxMacro{\@@latex@@printbibliography}{\printbibliography}
\renewcommand{\printbibliography}{%
  \phantomsection
  \addcontentsline{toc}{chapter}{Bibliography}
  \markboth{Bibliography}{}
  \chapter*{Bibliography}
  \sloppy % ensures that URLs can be broken at the end of the line
  \@@latex@@printbibliography[heading=none,notcategory=cvcitation,resetnumbers]%
  \fussy % back to normal 
}

% Index
\LetLtxMacro{\@@latex@@printindex}{\printindex}
\renewcommand{\printindex}{%
  \phantomsection
  \@@latex@@printindex
}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% TODO Notes
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\iftodonotes
  \RequirePackage[textwidth=.13\textwidth,textsize=footnotesize,colorinlistoftodos]{todonotes}
\else
  \RequirePackage[disable]{todonotes}
\fi
\presetkeys{todonotes}{fancyline}{}

\newcommand{\todoEmpty}[2][]{\todo[fancyline,#1]{#2}}
\newcommand{\todoMissing}[2][]{\todoEmpty[color=magenta!80,linecolor=magenta!80,#1]{Missing: #2}}
\newcommand{\todoCheck}[2][]{\todoEmpty[color=red!80,linecolor=red!80,#1]{Check: #2}}
\newcommand{\todoRevise}[2][]{\todoEmpty[color=orange!80,linecolor=orange!80,#1]{Revise: #2}}
\newcommand{\todoCitation}[2][]{\todoEmpty[color=yellow!80,linecolor=yellow!80,#1]{Citation: #2}}
\newcommand{\todoLanguage}[2][]{\todoEmpty[color=blue!40!white,linecolor=blue!40!white,#1]{Language: #2}}
\newcommand{\todoQuestion}[2][]{\todoEmpty[color=green!80!white,linecolor=green!80!white,#1]{Question: #2}}
\newcommand{\todoNote}[2][]{\todoEmpty[color=black!20!white,linecolor=black!20!white,#1]{Note: #2}}
\newcommand{\todoFigure}[6]{\begin{figure}\centering\missingfigure[figwidth=#1]{#2}\captionTBE{#3}{#4}{#5}\label{#6}\end{figure}}

%% END THESIS.CLS
