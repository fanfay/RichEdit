

Quill.prototype.getHtml = function() {
    return this.container.querySelector('.ql-editor').innerHTML;
};

// 从原生端打印日志
function sendMessage(name, params = ""){
    window.webkit.messageHandlers[name].postMessage(params)
}

// 监听文本编辑
quill.on("editor-change", event => {
    window.sendMessage('logger', quill.getFormat())
    window.sendMessage('actions', quill.getFormat())
});

// 失去焦点
function blur() {
    quill.blur()
}

// 获得焦点
function focus() {
    window.sendMessage('logger', "focus")
    quill.focus()
}

// 是否获得焦点
function hasFocus() {
    var focus = quill.hasFocus()
    window.sendMessage('logger', focus)
}

// 更新
function update() {
    quill.update()
}

// format
function setBold(val) {
    quill.format('bold', val)
}

function setItalic(val) {
    quill.format('italic', val)
}

function setScript(val) {
    quill.format('script', val)
}

function setUnderline(val) {
    quill.format('underline', val)
}

function setStrike(val){
    quill.format('strike', val)
}

function setIndent(val){
    quill.format('indent', val)
}
function setHeader(val) {
    quill.format('header', val);
}

function setSize(val) {
    quill.format('size', val);
}

function setAlign(val) {
    quill.format('align', val);
}

function setBlockquote(val) {
    quill.format('blockquote', val);
}

function setCodeblock(val) {
    quill.format('code-block', val);
}

// ordered & bullet
function setList(val){
    quill.format('list', val)
}

// undo
function undo() {
    quill.history.undo();
}

// redo
function redo() {
   quill.history.redo()
}


function setLink(val) {
    quill.format('link', val)
}

function setColor(val){
    quill.format('color', val)
}

function setBackgroundColor(val){
    quill.format('background', val)
}

function removeAllFormat() {
    var selection = quill.getSelection()
    quill.removeFormat(0,selection.index)

}

function insertImage(path){
    var selection = quill.getSelection()
    quill.insertEmbed(selection, 'image', path);
    selection = quill.getSelection()
    quill.setSelection(selection.index+2,1)
}

// 导出
function getHtml() {
    var html = quill.getHtml()
    return html
}

// 导入
function insertContent(content){
    quill.container.querySelector('.ql-editor').innerHTML = content
}

