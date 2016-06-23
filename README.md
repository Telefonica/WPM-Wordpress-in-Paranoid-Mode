WordPress in Paranoid Mode (WPM)
================================

Is a tool for Hardening WordPress.

Requisites
----------

1. Create an App in [latch.eleventpaths.com](https://latch.elevenpaths.com)
2. Get an **APP ID** and **SECRET**

Install
-------

Installing WPM requires you to execute one console command:

```bash
./install.sh <APP ID> <SECRET>
```

This steps are automatic through of this script:

 * Step 1: Give me a token (Latch)
 * Step 2: Pairing
 * Step 3: Copying files and create operations
 * Step 4: Install bundles (Libraries MySQL)
 * Step 5: Configure AppArmor
 * Step 6: Dump Triggers on MySQL

Uninstall
---------

In Directory "remove/" execute:

```bash
./delete.sh
```

**< NOTE >** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
	KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
	WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
	PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
	OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
	OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

This software doesn't have a QA Process. This software is a Proof of Concept.

For more information please visit [www.elevenpaths.com](http://www.elevenpaths.com)
