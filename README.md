# obsidian-zotero-pandoc-odt: A workflow for managing Zotero references in Obsidian and exporting them to LibreOffice

As anyone who knows me knows, I'm a big fan of both Obsidian and Zotero. Obsidian is where I write all of my notes, reflections, and publishable work, while Zotero is where I maintain my bibliographies, annotate manuscripts, and organize PDFs of articles and other documents. One of Zotero's advantages is that I can work with my documents directly within the application, whether on my MacBook or iPad. I can even use the Apple Pencil to annotate PDFs in Zotero on my iPad.

I moved to Obsidian about two and a half years ago from another favorite application, Scrivener. I made the switch because I wanted more control over my documents and how I organized them. Although Scrivener stores individual documents as RTF files, it manages them within a project structure that makes their organizational relationships difficult to discern outside the application. Obsidian, by contrast, works directly with my own file and folder structure. I can organize and manage my documents in Finder, independently of Obsidian, while retaining that same organization within the application. I also wanted a more minimal writing environment, which Obsidian provides through its use of Markdown.

Markdown is central to my writing. At its core, a Markdown file is a plain-text document that remains human-readable, even with its formatting syntax. The format is relatively simple, works across operating systems and applications, and produces small files that are easy to store and manage. Because the formatting doesn't obscure the text, I can open and read my documents in almost any text editor without depending on a particular application. This differs from Microsoft Word's DOCX format, which packages a collection of XML files and other resources into a compressed archive. Although DOCX is a documented, standardized format, its underlying structure is considerably more complex than Markdown and is not intended to be read directly in a text editor.

The challenge, of course, is that most people don't use Markdown. When sharing manuscripts, articles, or other documents, I generally need to convert my Markdown files into a format that others can open, read, and edit. Whenever possible, I prefer open-source software, so I usually turn to LibreOffice rather than Microsoft Word. LibreOffice provides the document-editing and formatting capabilities I need, and it works well with Zotero, which allows me to manage citations and bibliographies directly within my documents.

This brings me to one of the challenges of my writing environment. As with Scrivener, integrating Obsidian with a bibliographic reference manager such as Zotero requires some additional configuration. Obsidian offers considerable flexibility, but establishing a workflow that connects notes, bibliographic references, citations, and finished manuscripts takes some work. Converting Markdown into a LibreOffice document introduces an additional consideration: citations written in Markdown do not automatically become editable Zotero citations. Managing that transition requires a workflow that preserves bibliographic information while moving between applications.

A number of solutions are available online, many developed by scholars who use Obsidian and Zotero in their research and writing. I thought it would be useful to share my own setup and workflow in an approachable way, particularly for others who want to integrate Obsidian, Zotero, and LibreOffice into their writing process. I use a Mac, and while it should work, I have not verified that this setup works on Linux or Microsoft machines. 

## Setup
In this section, I outline my setup. It may look complicated, but it is relatively easy to set up if you follow each step. You need to do it only once. 

### Installations
Here is a list of everything we will install and what it does. You may already have some of these installed on your computer. If so, you may want to make sure that your version is up to date. 

| Component                            | Role in the workflow                                                                                                                                                                                     |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Obsidian**                         | Where I write and organize my Markdown manuscripts.                                                                                                                                                      |
| **Zotero**                           | My research library, where I manage bibliographic information, PDFs, and annotations.                                                                                                                    |
| **Better BibTeX**                    | A Zotero plugin that provides stable citation keys and a local service for resolving them during conversion.                                                                                             |
| **Pandoc**                           | Converts Markdown manuscripts into LibreOffice-compatible ODT documents.                                                                                                                                 |
| **Pandoc Reference List (optional)** | Reads a Better BibTeX bibliography file and displays formatted references for citation keys in the open Obsidian note.                                                                                   |
| **LibreOffice Writer**               | The word processor I use to review, edit, and prepare manuscripts for sharing or publication.                                                                                                            |
| **Zotero LibreOffice add-in**        | Integrates Zotero with Libre Office Writer, a word processor similar to Microsoft Word, allowing me to insert and edit citations, change citation styles, refresh references, and manage bibliographies. |
| **Better BibTeX `zotero.lua`**       | A Pandoc Lua filter that resolves citation keys through Zotero and embeds editable Zotero citation fields in the exported ODT document.                                                                  |
| **`convert-to-odt.sh`**              | A macOS shell script that automates the conversion, works from a temporary copy, prompts before overwriting existing files, and accepts drag-and-drop input.                                             |

#### Install Obsidian

1. Go to the official [Obsidian download page](https://obsidian.md/download).
2. Under Mac, select **Universal**.
3. Open the installer and drag Obsidian into **Applications**.
4. Open Obsidian.
5. Choose **Create new vault** or **Open folder as vault**.

Official instructions: [Download and install Obsidian](https://help.obsidian.md/install).


#### Install Zotero

1. Download [Zotero for Mac](https://www.zotero.org/download/).
2. Open the `.dmg`.
3. Drag Zotero into **Applications**.
4. Open Zotero and let it update.
5. Add at least one item to your library and correct its author, title, date, and item type. Zotero can format only the data it has.

The browser connector is useful for collecting sources but is not required for the conversion itself. Zotero's official installation page explains how to install it: [Zotero installation](https://www.zotero.org/support/installation).


#### Install Better BibTeX
Better BibTeX is a Zotero plugin. It supplies stable citation keys and the local service used by the Pandoc filter.

1. Go to the [latest Better BibTeX release](https://github.com/retorquere/zotero-better-bibtex/releases/latest).
2. Download the release `.xpi` file. If Firefox tries to install it as a browser extension, right-click the download link and save the file instead.
3. In Zotero, choose **Tools → Plugins**.
4. In the plugin manager, click the gear menu.
5. Choose **Install Plugin From File…**.
6. Select the `.xpi`, install it, and restart Zotero if prompted.
7. Open Zotero settings and confirm that Better BibTeX settings are available.

Better BibTeX should auto-update after installation. Check its official instructions if the menus differ in a newer Zotero version: [Better BibTeX installation](https://retorque.re/zotero-better-bibtex/installation/).

#### Configure Quick Copy for Pandoc citations
Pandoc Reference List, which you will install later, shows formatted references but does not supply a citation picker. Better BibTeX's Quick Copy feature provides a simple way to move citation keys from Zotero into Obsidian:
1. Open Zotero's **Export** settings.
2. Choose **Better BibTeX Quick Copy** as the Quick Copy format.
3. In Better BibTeX's export settings, set the Quick Copy/drag-and-drop format to **Pandoc citation**.
4. Enable **Surround Pandoc citations with brackets** if you want a pasted item to arrive as a complete parenthetical citation.
5. Select one or more Zotero items and press **Command-Shift-C**, Zotero's macOS shortcut for Quick Copy, then paste into Obsidian. Alternatively, drag the selected items directly into the Obsidian editor.

Depending on the bracket option and the number of selected items, the result will resemble `@key` or `[@key; @secondKey]`. Add locators such as `, p. 42` in Obsidian. You can also read the **Citation Key** column and type the key manually.


#### Install Pandoc

##### Recommended: official macOS installer
1. Open [Pandoc's installation page](https://pandoc.org/installing.html).
2. Download the latest macOS installer.
3. Open the package and follow the prompts.
4. Close and reopen Terminal so it sees the installed command.
5. Verify:

```bash
pandoc --version
```

The version must be at least 2.16.2 for the Better BibTeX filter, but use a current release unless you have a compatibility reason not to.

##### Alternative: Homebrew

If Homebrew is already installed:

```bash
brew install pandoc
```

Do not install Pandoc by several methods at once. Multiple copies can make it unclear which version your script is using. Check with:

```bash
command -v pandoc
pandoc --version
```


#### Install Pandoc Reference List (Optional)
This guide uses the original [Pandoc Reference List](https://community.obsidian.md/plugins/obsidian-pandoc-reference-list). It has a long history, but its repository is now archived and its community listing says it was last updated several years ago. The plugin is therefore an optional preview convenience, not a dependency of the conversion pipeline.

##### Create a Better BibTeX auto-export
1. In Zotero, decide whether you want to export your entire library, or a sub-collection. This export will be the basis for previewing citations in Obsidian. 
2. In Zotero's left sidebar, right-click that library or collection.
3. Choose **Export Library…** or **Export Collection…**.
4. Select **Better BibTeX** as the export format.
5. Enable **Keep updated**.
6. Leave **Export Notes** and **Export Files** disabled unless you have a separate reason to include them.
7. Save the file as `references.bib` in a stable location inside your Obsidian vault, for example:

```text
/Users/example/Documents/Obsidian/My Research Vault/Bibliography/references.bib
```

##### Install and configure the Pandoc Reference plugin

1. Open Zotero and confirm Better BibTeX is enabled.
2. In Obsidian, open **Settings → Community plugins**.
3. Turn on community plugins if necessary, then select **Browse**.
4. Search for the exact name **Pandoc Reference List**.
5. Select **Install**, then **Enable**.
6. Open the plugin settings.
7. Turn on **Pull bibliography from Zotero**.
8. Leave **Zotero port** at its default, normally `23119`, unless you deliberately changed Better BibTeX's local-service port.
9. Select the personal or group Zotero libraries to include.
10. Leave **Bibliography path** empty. That setting belongs to the alternative file-based workflow and is not needed here.

Despite its label, **Pull bibliography from Zotero** in this plugin obtains the bibliography through Better BibTeX's local service. Zotero and Better BibTeX therefore need to be running when the plugin first loads or refreshes the bibliography. 

Because the repository is archived, compatibility with future Zotero and Better BibTeX releases is not guaranteed. A failed preview does not invalidate the separate `zotero.lua` conversion path.

#### Verify the connection
1. Create a disposable Obsidian note.
2. Enter a known key manually, or paste a Pandoc citation copied from Zotero using Better BibTeX Quick Copy.
3. Confirm the source contains portable Pandoc syntax such as:

```
[@scottGenderUsefulCategory1986, p. 1067]
```

4. Open the Command Palette (command+p) and run **Pandoc Reference List: Show reference list**.
5. Confirm the source appears in the sidebar.

If a new Zotero item does not appear, first confirm it belongs to the library or collection you exported. Keep Zotero open long enough for Better BibTeX to update `references.bib`, then reopen the reference sidebar. 

Pandoc Reference List is a writing and preview layer. It does not create the live fields in the ODT, and the converter does not rely on its `.bib` file. Better BibTeX's `zotero.lua` performs the live-field job during conversion, and Zotero's LibreOffice add-in manages the fields after export. If the archived plugin becomes incompatible, disable it and continue using `[@key]` citations; conversion will still work.


#### Install LibreOffice
1. Go to [LibreOffice downloads](https://www.libreoffice.org/download/).
2. Choose Apple Silicon for M-series Macs or Intel for an Intel Mac.
3. Install LibreOffice in Applications.
4. Open Writer once, then close it before installing the Zotero add-in.

#### Install Zotero's LibreOffice integration

The add-in is bundled with Zotero
1. Close LibreOffice.
2. Open Zotero.
3. Open **Zotero → Settings → Cite → Word Processors**.
4. Click **Install LibreOffice Add-in** or **(Re)install LibreOffice Add-in**.
5. Restart LibreOffice Writer.
6. Look for the Zotero toolbar or commands.



#### Set Up Your Conversion Folder

You can set up your Conversion folder anywhere you like, and you can name it what you want. For this example, we will use the Documents folder and name the conversion folder `obsidian-odt-converter`. 


#### Download the `zotero.lua` Filter

Open the **Terminal** application on your computer and navigate into your `obsidian-odt-converter` folder. 
1. Open **Finder** and locate your `obsidian-odt-converter` folder.
2. Open **Terminal**. You can find it under **Applications → Utilities**, or press **Command-Space**, type `Terminal`, and press **Return**.
3. In Terminal, type the following, including the space after `cd`:

```bash
cd 
```

4. Drag the `obsidian-odt-converter` folder from Finder into the Terminal window. Terminal will insert the folder’s location for you.
5. Press **Return**.

Terminal is now working inside the conversion folder. The command `cd` simply means “change folder.” Nothing has been installed, moved, or altered.

##### Download the current filter

Type the following into Terminal:

```
curl -L "https://retorque.re/zotero-better-bibtex/exporting/zotero.lua" -o zotero.lua
```

Confirm that `zotero.lua` appears with a file size greater than zero:

```
ls -lh zotero.lua
```

###### What the filter does

During conversion, `zotero.lua`:
- sends the manuscript’s citation keys to Better BibTeX in the running Zotero application;
- matches those keys to Zotero items; and
- writes live Zotero citation and bibliography data into the ODT.


#### Download the Obsidian-ODT-Converter Program
Download [convert-to-odt.sh]([convert-to-odt.sh](https://github.com/6500jmk4/obsidian-zotero-pandoc-odt/blob/main/convert-to-odt.sh)) and save it in this the conversion beside `zotero.lua`. Keep the filename exactly `convert-to-odt.sh`. 

In Terminal, enter `chmod +x `, including the final space. Drag `convert-to-odt.sh` into Terminal and press **Return**.

The completed command will resemble:

```bash
chmod +x /Users/your-name/Documents/Obsidian-ODT-Converter/convert-to-odt.sh
```

You will need to enter this command once. 


#### Convert Markdown to ODT with Live Zotero References

1. Keep **Zotero open**. Better BibTeX must be active.
2. Open **Terminal**.
3. Drag `convert-to-odt.sh` from Finder into Terminal and press **Return**. This will start the program
4. When the script asks for a manuscript, drag your markdown document from Finder into Terminal and press **Return**.
5. If asked about overwriting an existing ODT, answer `y` only if you are willing to replace it.
6. When asked whether to open the result in LibreOffice, enter `y`.

The output appears in the `converted` folder unless you configured another output location.

The script works on a temporary copy. It does not edit or delete the original Markdown file. Temporary files are normally removed automatically when the script ends.


#### Seeing Your Citations in LibreOffice 

When your ODT file first opens in LibreOffice:
1. Keep Zotero open.
2. In the Zotero toolbar, choose **Document Preferences**.
3. Select the required style—for example, a Chicago note style—and click **OK**.
4. Then click **Refresh**.
5. Inspect the citation, footnote, bibliography, table, and text after the horizontal rule.

Never click **Unlink Citations** on your working copy. Unlinking converts fields to ordinary text and is irreversible. Use it only on a final duplicate if a publisher specifically requires plain text.


> [!NOTE]
> ### How citations work between Zotero and Obsidian
>
> Zotero stores your sources. Obsidian is where you write. Pandoc provides a way to refer to those sources so they can become formatted citations later.
>
> Instead of typing a citation by hand, such as `(Scott, 1986, p. 1067)`, insert a short reference in Obsidian:
>
> `[@scottGenderUsefulCategory1986, p. 1067]`
>
> This is a **Pandoc citation**. The string beginning with `@` is the source’s **citation key**—a unique identifier assigned by Better BibTeX.
>
> When you export your writing, Pandoc uses that key to find the correct Zotero item. The citation is then formatted in your chosen style, such as Chicago, APA, or MLA.
>
> You do not need to memorize citation keys. Pandoc Reference List can suggest them as you type, or you can copy them from Zotero using Better BibTeX Quick Copy.
>
> #### Finding citation keys in Zotero
>
> Select an item in Zotero. Its citation key appears in the **Info** panel on the right. You can copy that key into your Obsidian document.
>
> A Markdown manuscript stores the key—not the complete bibliographic record. If a key changes in Zotero, citations containing the old key may no longer resolve.
>
> Before beginning a long project:
>
> - settle on a citation-key pattern;
> - avoid regenerating keys without a reason;
> - update the manuscript if you intentionally change a key; and
> - keep Zotero synchronized and backed up.
>
> Changing Better BibTeX’s key formula generally does not change existing keys until you explicitly regenerate them. See [Better BibTeX citation keys](https://retorque.re/zotero-better-bibtex/citing/).
>
> #### 1. Citing a source
>
> Add the source in square brackets:
>
> ```markdown
> This interpretation has been influential [@scottGenderUsefulCategory1986].
> ```
>
> The `@` introduces a citation key. The square brackets tell Pandoc to treat it as a parenthetical citation or its equivalent in the selected style.
>
> ##### Optional Quick Copy from Zotero
>
> Better BibTeX can copy or drag a Pandoc citation such as `[@key]` into Obsidian. This requires a one-time setup:
>
> 1. In Better BibTeX’s preferences, select **Pandoc citation** as the Quick Copy format.
> 2. In Zotero’s Export preferences, select **Better BibTeX Quick Copy** as the default format.
>
> Because menu names can change, consult the current [Better BibTeX citation instructions](https://retorque.re/zotero-better-bibtex/citing/) if your options look different. Typing `[@key]` manually remains valid.
>
> #### 2. Citing a specific page
>
> Add a page number after a comma:
>
> ```markdown
> This argument appears in Scott's essay [@scottGenderUsefulCategory1986, p. 1067].
> ```
>
> For several pages, use `pp.`:
>
> ```markdown
> Scott develops this argument [@scottGenderUsefulCategory1986, pp. 1067–1070].
> ```
>
> #### 3. Citing more than one source
>
> Put the sources inside one pair of square brackets, separated by a semicolon:
>
> ```markdown
> Historians have debated this question [@scottGenderUsefulCategory1986; @vickeryGoldenAgeSeparate1993].
> ```
>
> #### 4. Adding words such as “see” or “compare”
>
> You can include short instructions inside a citation:
>
> ```markdown
> This distinction has been debated [see @scottGenderUsefulCategory1986, p. 1067; compare @vickeryGoldenAgeSeparate1993, chap. 2].
> ```
>
> Words such as `see` and `compare` appear in the formatted citation.
>
> #### 5. When you already mention the author
>
> To avoid repeating the author’s name, place a minus sign before `@`:
>
> ```markdown
> Scott makes this point explicitly [-@scottGenderUsefulCategory1986, p. 1067].
> ```
>
> The `-@` tells Pandoc to omit the author’s name from the formatted citation. This is particularly useful in author-date styles.
>
> Pandoc also supports an author-in-text form:
>
> ```markdown
> @scottGenderUsefulCategory1986 argues that gender is relational.
> ```
>
> Better BibTeX’s live-citation filter treats author-in-text citations as an optional or emulated feature. Test this form with your filter version and citation style before using it throughout a manuscript.
>
> #### 6. Putting citations in footnotes
>
> A citation can appear inside an Obsidian Markdown footnote:
>
> ```markdown
> This terminology requires qualification.[^1]
>
> [^1]: See [@scottGenderUsefulCategory1986, pp. 1067–1070].
> ```
>
> In this workflow, the Markdown footnote becomes a LibreOffice footnote containing the live Zotero citation.
>
> For the complete syntax, see [Pandoc’s official citation documentation](https://pandoc.org/demo/example1.html#citations).
