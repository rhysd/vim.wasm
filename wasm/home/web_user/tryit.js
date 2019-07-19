/*
 * WELCOME TO LIVE DEMO OF https://github.com/rhysd/vim.wasm !
 *
 * - Almost all powerful Vim features (text objects, syntax highlighting, Vim script, ...)
 *   including latest features (popup window, ...) are supported.
 *
 * - Drag&Drop files to browser tab opens them in Vim.
 *
 * - `:write` only writes file on memory.  Download current buffer by `:export` or
 *   specific file by `:export {file}`.
 *
 * - Clipboard register `"*` is supported.  For example, paste system clipboard text.
 *   - Paste system clipboard text *   to Vim with `"*p` or `:put *`.
 *   - Copy text in Vim to system clipboard with `"*y` or `:yank *`.
 *   - `:set clipboard=unnamed` is available to synchronize clipboard.
 *
 * - `~/.vim/vimrc` (NOT `~/.vimrc`) is your vimrc. It is persistently stored to
 *   Indexed DB on `:quit`.
 *
 * - Default colorscheme is onedark, but monokai is also available as high-contrast
 *   colorscheme.
 *
 * - `:!/path/to/file.js` evaluates the JavaScript code in browser.
 *   `:!%` evaluates current buffer.
 *
 * - vimtutor is available by `:e tutor`.
 *
 * - Add `arg=` query parameters to add `vim` command line arguments.
 *
 * - `:edit ~/README.md` for more details.
 *
 * - Please try `:Explore` (Netrw plugin) for browsing filesystem.
 */

// MinHeap and Heap Sort Example
// Run it with :!%

class MinHeap {
    constructor() {
        // Array representation of the heap.
        this.heap = [];
    }

    pop() {
        if (this.heap.length === 0) {
            return null;
        }

        if (this.heap.length === 1) {
            return this.heap.pop();
        }

        const item = this.heap[0];

        this.heap[0] = this.heap.pop();
        this._heapifyDown();

        return item;
    }

    push(...items) {
        for (const item of items) {
            this.heap.push(item);
            this._heapifyUp();
        }
    }

    isEmpty() {
        return this.heap.length === 0;
    }

    _heapifyUp(startIdx) {
        let idx = startIdx || this.heap.length - 1;

        while (this._hasParent(idx) && this._parent(idx) > this.heap[idx]) {
            this._swap(idx, this._parentIndex(idx));
            idx = this._parentIndex(idx);
        }
    }

    _heapifyDown(startIdx = 0) {
        let idx = startIdx;
        let nextIdx = null;

        while (this._hasLeftChild(idx)) {
            if (this._hasRightChild(idx) && this._rightChild(idx) <= this._leftChild(idx)) {
                nextIdx = this._rightChildIndex(idx);
            } else {
                nextIdx = this._leftChildIndex(idx);
            }

            if (this.heap[idx] <= this.heap[nextIdx]) {
                break;
            }

            this._swap(idx, nextIdx);
            idx = nextIdx;
        }
    }

    _leftChildIndex(parent) {
        return 2 * parent + 1;
    }

    _rightChildIndex(parent) {
        return 2 * parent + 2;
    }

    _parentIndex(child) {
        return Math.floor((child - 1) / 2);
    }

    _hasParent(child) {
        return this._parentIndex(child) >= 0;
    }

    _hasLeftChild(parent) {
        return this._leftChildIndex(parent) < this.heap.length;
    }

    _hasRightChild(parent) {
        return this._rightChildIndex(parent) < this.heap.length;
    }

    _leftChild(parent) {
        return this.heap[this._leftChildIndex(parent)];
    }

    _rightChild(parent) {
        return this.heap[this._rightChildIndex(parent)];
    }

    _parent(child) {
        return this.heap[this._parentIndex(child)];
    }

    _swap(lhs, rhs) {
        [this.heap[lhs], this.heap[rhs]] = [this.heap[rhs], this.heap[lhs]];
    }
}

function heapSort(arr) {
    const heap = new MinHeap();
    heap.push(...arr);
    const sorted = [];
    while (!heap.isEmpty()) {
        sorted.push(heap.pop());
    }
    return sorted;
}

function randomNumber(min, max) {
    return (Math.random() * (max - min) + min) | 0;
}

function main() {
    const len = randomNumber(1, 20);
    const before = Array(len)
        .fill(undefined)
        .map(_ => randomNumber(1, 100));
    const after = heapSort(before);
    const result = `BEFORE: ${before}\n\nAFTER: ${after}`;
    alert(result);
}

main();
