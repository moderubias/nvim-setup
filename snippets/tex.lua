local parse = require("luasnip").parser.parse_snippet
local snippets = {}
local function add(trigger, description, body)
  snippets[#snippets + 1] = parse({ trig = trigger, name = description, dscr = description, priority = 1100 }, body)
end

add(
  "xedoc",
  "XeLaTeX document · Russian and English",
  [=[
% !TeX program = xelatex
\documentclass[12pt,a4paper]{article}
\usepackage{fontspec}
\setmainfont{Libertinus Serif}
\usepackage{polyglossia}
\setdefaultlanguage{russian}
\setotherlanguage{english}
\usepackage{amsmath,amssymb}
\usepackage{graphicx,booktabs,microtype}
\usepackage[margin=25mm]{geometry}
\usepackage[hidelinks]{hyperref}
\title{${1:Название}}
\author{${2:Автор}}
\date{\today}

\begin{document}
\maketitle
$0
\end{document}
]=]
)
add(
  "beg",
  "Environment with matching end",
  [=[\begin{${1:environment}}
  $0
\end{$1}]=]
)
add(
  "eqn",
  "Numbered equation and label",
  [=[\begin{equation}
  \label{eq:${1:name}}
  $0
\end{equation}]=]
)
add(
  "align",
  "Aligned equations",
  [=[\begin{align}
  ${1:a} &= ${2:b} \\
  ${3:c} &= ${4:d}
\end{align}
$0]=]
)
add(
  "dm",
  "Display mathematics",
  [=[\[
  $0
\]]=]
)
add("mm", "Inline mathematics", [=[\(${1}\)$0]=])
add("frac", "Fraction", [=[\frac{${1:numerator}}{${2:denominator}}$0]=])
add("sum", "Sum with limits", [=[\sum_{${1:i=1}}^{${2:n}} ${0}]=])
add("int", "Integral with differential", [=[\int_{${1:a}}^{${2:b}} ${3:f(x)}\,\mathrm{d}${4:x}$0]=])
add(
  "fig",
  "Figure, caption and label",
  [=[\begin{figure}[htbp]
  \centering
  \includegraphics[width=${1:0.8}\linewidth]{${2:filename}}
  \caption{${3:Caption}}
  \label{fig:${4:name}}
\end{figure}
$0]=]
)
add(
  "tbl",
  "Booktabs table",
  [=[\begin{table}[htbp]
  \centering
  \caption{${1:Caption}}
  \label{tab:${2:name}}
  \begin{tabular}{${3:ll}}
    \toprule
    ${4:First} & ${5:Second} \\
    \midrule
    ${6:Value} & ${7:Value} \\
    \bottomrule
  \end{tabular}
\end{table}
$0]=]
)
add(
  "itemize",
  "Bullet list",
  [=[\begin{itemize}
  \item $0
\end{itemize}]=]
)
add(
  "enum",
  "Numbered list",
  [=[\begin{enumerate}
  \item $0
\end{enumerate}]=]
)
add(
  "sec",
  "Section with label",
  [=[\section{${1:Title}}
\label{sec:${2:name}}
$0]=]
)
add(
  "ssec",
  "Subsection with label",
  [=[\subsection{${1:Title}}
\label{sec:${2:name}}
$0]=]
)
add("ref", "Nonbreaking cross-reference", [=[~\ref{${1:label}}$0]=])
add("cite", "Citation", [=[\cite{${1:key}}$0]=])
add(
  "theorem",
  "Theorem (requires amsthm and newtheorem)",
  [=[\begin{theorem}[${1:Name}]
  \label{thm:${2:name}}
  $0
\end{theorem}]=]
)
add(
  "proof",
  "Proof (requires amsthm)",
  [=[\begin{proof}
  $0
\end{proof}]=]
)
add("pkg", "Load a LaTeX package", [=[\usepackage[${1:options}]{${2:package}}$0]=])
add(
  "cmd",
  "Document command with argument signature",
  [=[\NewDocumentCommand{\${1:command}}{${2:m}}{%
  $0
}]=]
)
add(
  "expl",
  "Expl3 code block",
  [=[\ExplSyntaxOn
$0
\ExplSyntaxOff]=]
)

return snippets
