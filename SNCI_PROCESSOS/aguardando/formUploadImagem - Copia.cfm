<cfif isDefined("form.formListFile") >
    <cfparam name="form.acao" default="#form.acao#">
<cfelse>
    <cfparam name="form.acao" default="">
</cfif>
<!---<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_login#">)
</cfquery>--->
<cfset limiteImagens = false>
<cfif isDefined('form.grupo')>
     <cfif '#url.editor#' neq 'Melhoria' >
          
          <cfif '#form.dir#' eq 'imagens'>

               <cfset diretorio = imagesDirOrientacoes & '/' & '#form.grupo#' & '_' & '#form.item#' &'/' >
          <cfelse>
               <cfset diretorio = imagesDirIcones &'/' >
          </cfif>
     <cfelse>
           <cfset diretorio = imagesDirAvaliacoes & '/' & '#form.insp#' & '_' & '#form.grupo#' & '_' & '#form.item#' &'/' >     
     </cfif>
     <cfif directoryExists(diretorio)>
          <cfdirectory action="list" directory="#diretorio#" recurse="false" name="myList">
     <cfelse>
          <cfdirectory action="create" directory="#diretorio#">
     </cfif>
     <cfset imagesPath = diretorio />

     <!---Verifica se o limite de imagens foi atigindopara os perfis inspetores e gestores--->
     <cfdirectory action="list" directory="#imagesPath#" recurse="false" listinfo="name" name="myList" sort = "datelastmodified Desc" filter="*.png|*.jpg|*.jpeg|*.gif">
     <cfif '#myList.RecordCount#' ge 6>
          <cfset limiteImagens = true>
     </cfif>
     

     <cfif (Form.acao neq "deletar") and Form.uploadFile neq ''>        
          <cfset uploadPath = getTempDirectory() />
         <cfset acceptMimeTypes = "image/*" />
          <cfif '#form.dir#' eq 'imagens'>
               <cfset acceptExtensions = "gif,jpeg,jpg,png" />
          <cfelse>
              <cfset acceptExtensions = "png,gif,jpg" />
          </cfif>
          <!--- Process file upload, if form submitted --->
          <cfif structKeyExists(form, "uploadFile")>
               <!--- Catch error if MIME type is not accepted --->
                <cftry>
                    <cffile action="upload" filefield="uploadFile" destination="#uploadPath#" accept="#acceptMimeTypes#" nameConflict="makeUnique" result="uploadResult" />
                    <cfcatch type="any">
                         <script language="JavaScript">
                         <cfif '#form.dir#' eq 'imagens'>
                              var erro = "ERRO: O tipo de arquivo carregado (<cfoutput>#cfcatch.MimeType#</cfoutput>) n�o foi aceito pelo servidor.\n\nSomente arquivos do tipo gif, jpeg, jpg e png podem ser carregados.\n\nVerifique se voc� est� enviando um arquivo do tipo apropriado. ";
                              alert(erro);
                         <cfelse>
                              var erro = "ERRO: O tipo de arquivo carregado (<cfoutput>#cfcatch.MimeType#</cfoutput>) n�o foi aceito pelo servidor.\n\nSomente arquivos do tipo jpg e  png podem ser carregados.\n\nVerifique se voc� est� enviando um arquivo do tipo apropriado. ";
                              alert(erro);
                         </cfif>     
                              
                         </script>
                    </cfcatch>
                </cftry>
                <cfif isDefined("uploadResult")>
                    <script language="JavaScript">
                    //     alert("Imagem encaminhada com sucesso ao Servidor!\n\nClique na imagem para adicion�-la ao editor de texto.\n\nObs.: A �ltima imagem enviada sempre aparecer� na primeira fila � esquerda.")
                        location.href = location.href;
                    </script>
                </cfif>
          </cfif>
          
     </cfif>
</cfif>

<cfif IsDefined("FORM.acao") And Form.acao is "deletar">
     <cfif IsDefined("FORM.imagemDel") And Form.imagemDel neq ''>
          <cffile action = "delete" file = "#thisDir#/#Form.imagemDel#" />
     </cfif>
     <!---Verifica se o limite de imagens foi atigindopara os perfis inspetores e gestores--->
     <cfdirectory action="list" directory="#imagesPath#" recurse="false" listinfo="name" name="myList" sort = "datelastmodified Desc" filter="*.png|*.jpg|*.jpeg|*.gif">
     <cfif '#myList.RecordCount#' ge 6>
          <cfset limiteImagens = true>
     </cfif>
     <script language="JavaScript">
          location.href = location.href;
     </script>
</cfif>


<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<title>SNCI - UPLOAD DE IMAGENS</title>
     <link rel="stylesheet" type="text/css" href="view.css" media="all">
<link rel="stylesheet" type="easyimage/styles/easyimage.css" href="view.css" media="all">

     <script language="JavaScript">

     window.onload = function(){
          setTimeout('GrupoNaoDefinido();',500);
     }

     var loop = setInterval(function() {   
     if(window.opener.closed) {  
          clearInterval(loop);  
          window.close();  
     }  
     }, 1000); 

         

          function EnviarArquivoAvaliacoes(){
              
               if (document.getElementById("uploadFile").value != ''){
                    var insp = window.opener.document.getElementById('ninsp').value;
                    var grupo = window.opener.document.getElementById('ngrup').value;
                    var item = window.opener.document.getElementById('nitem').value;
                    <cfoutput>
                         var edt = '#url.editor#';
                         var dir = '#url.dir#';
                    </cfoutput>
                    document.getElementById('insp').value = insp;
                    document.getElementById('grupo').value = grupo;
                    document.getElementById('item').value = item;
                    document.getElementById('editor').value = edt;
                    document.getElementById('dir').value = dir;
                     
                    
                        
                    setTimeout('javascript:formListFile.submit();',2000);
                    aguarde();
               }
          }
     
          function EnviarArquivoOrientacoes(){
               if (document.getElementById("uploadFile").value != ''){
                    var grupo ="1";
                    var item = "1";
                    <cfoutput>
                          var edt = '#url.editor#';
                          var dir = '#url.dir#';
                    </cfoutput>
                    document.getElementById('grupo').value = grupo;
                    document.getElementById('item').value = item;
                    document.getElementById('editor').value = edt;
                    document.getElementById('dir').value = dir;

                    setTimeout('javascript:formListFile.submit();',2000);
                    aguarde();
               }
          }

          //In�cio do bloco de fun��es que controlam as linhas de uma tabela
          //remove a informa��o da linha clicada em uma tabela
          sessionStorage.removeItem('idLinha'); 
          //muda cor da linha ao passar o mouse (se a linha n�o tiver sido selecionada)
          function mouseOver(linha){ 
               if(linha.id !=sessionStorage.getItem('idLinha')){
                    linha.style.backgroundColor='#6699CC';
                    linha.style.color='#fff';
               }   
          }
          
          //restaura cor da linha ao retirar o mouse (se a linha n�o tiver sido selecionada)
          function mouseOut(linha){
               if(linha.id !=sessionStorage.getItem('idLinha')){
                    linha.style.backgroundColor = ''; 
                    linha.style.color='#053c7e'; 
               }else{
                    linha.style.backgroundColor='#053c7e';
                    linha.style.color='#fff';
               }
               
          }
          //Ao clicar grava a linha clicada, muda a cor da linha clicada e restaura a cor da linha clicada anteriormente
          function gravaOrdLinha(linha){ 
               if(sessionStorage.getItem('idLinha')!=null){
                    linhaselecionadaAnterior = document.getElementById(sessionStorage.getItem('idLinha'));
                    linhaselecionadaAnterior.style.backgroundColor = ''; 
                    linhaselecionadaAnterior.style.color='#053c7e'; 
               }
               var linhaClicada = linha.id;       
               sessionStorage.setItem('idLinha', linhaClicada);						
               linha.style.backgroundColor='#053c7e';
               linha.style.color='#fff';
          }
          //Fim do bloco de fun��es que controlam as linhas de uma tabela	

          var frm = document.getElementById('formListFile');
          function ExcluirImagem(file, name){ 
               if(window.confirm('Confirma a exclus�o desta imagem?\n'+ name)){
                    document.getElementById('imagemDel').value=file; 
                    document.getElementById('acao').value='deletar';
                    <cfif '#url.editor#' neq 'Melhoria' >
                         var grupo = '1';
                         var item = '1';
                    <cfelse>
                         var insp = window.opener.document.getElementById('ninsp').value;
                         var grupo = window.opener.document.getElementById('ngrup').value;
                         var item = window.opener.document.getElementById('nItem').value;
                         document.getElementById('insp').value = insp;
                    </cfif>
                    <cfoutput>
                         var edt = '#url.editor#';
                         var dir = '#url.dir#';
                    </cfoutput>
                    document.getElementById('grupo').value = grupo;
                    document.getElementById('item').value = item;
                    document.getElementById('editor').value = edt;
                    document.getElementById('dir').value = dir;
                    aguarde();
                    setTimeout('javascript:formListFile.submit();',2000);
                    // document.getElementById("formListFile").submit();
               }     
          }

          //fun��o que aciona a espera do submit
          function aguarde(t){
               t="formListFile";
               if(t !== undefined){
                    topo = 100 + document.getElementById(t).offsetTop;
               }else{
                    topo = '200';
               }
                    if(document.getElementById("aguarde").style.visibility == "visible"){
                         document.getElementById("aguarde").style.visibility = "hidden" ;
                         document.getElementById("main_body").style.cursor='auto';
                    }else{
                         document.getElementById("main_body").style.cursor='progress';
                         document.getElementById("aguarde").style.visibility = "visible";
                         piscando();
                    }
                    
                    document.getElementById("imgAguarde").style.top = topo + 'px';
          }

          function piscando(){
               img = document.getElementById("imgAguarde");
               fundo = document.getElementById("aguarde");                
               if(img.style.visibility == "hidden" & fundo.style.visibility == "visible"){                              
               img.style.visibility = "visible";                         
               }else{                   
               img.style.visibility = "hidden";                       
               }
               
               setTimeout('piscando()', 500);

          }
     
          function CopiaUrl(url){//n�o utilizado neste form
               var content = "IMAGENS_ORIENTACOES/" + url.innerHTML;
               window.clipboardData.setData("Text", content);
          }

          function InsereImagem(img,largura){
              
               <cfoutput>
                    var edt = '#url.editor#';
                    var dir ='#url.dir#';
               </cfoutput>
               var editor = window.opener.CKEDITOR.instances[edt];
               if(largura >'500'){
                    largura = '500';
               }
                var imagemHtml = '';
                var newwindow = "window.open('" + img + "', '_blank', 'width=900,height=500,toolbar=no,location=no, directories=no, status=no, menubar=no,scrollbars=yes, copyhistory=no,resizable=yes')";
                    
               <cfif '#url.editor#' neq 'Melhoria' >
                    
                    

                   if(dir == 'imagens'){
                        
                              imagemHtml = '<figure class="easyimage " ><img style="cursor:pointer" onclick="' + newwindow  + '" src=' + img + ' width="'+ largura + '" ></figure>';
                         
                    }else{
                        
                        
                              imagemHtml = '<figure class="easyimage " ><img   src=' + img + ' width="'+ largura + '" ></figure>';
                        
                    }
               <cfelse>
                   imagemHtml = '<figure class="easyimage "><img onclick="' + newwindow  + '" src=' + img + ' width="'+ largura + '"  style="cursor:pointer;""></figure>';     
               </cfif>
               editor.insertHtml(imagemHtml);
               editor.showNotification( 'Imagem inserida com sucesso!' );
               setTimeout('window.focus()',1000);  
          }

          function MudaPasta(){
               <cfoutput>
                    var edt = '#url.editor#';
                    var dir = "#url.dir#";
               </cfoutput>

               if (dir == 'imagens'){
                    url = 'formUploadImagem.cfm?editor=' + edt + '&dir=icones'; 
                    //  sessionStorage.setItem('dirImagens','icones');  
               }else{
                    url = 'formUploadImagem.cfm?editor=' + edt + '&dir=imagens';
                    // sessionStorage.setItem('dirImagens','imagens');
               }
                window.open(url, '_self'); 
          }
 
         
     </script>
     
<style>

     .divImagem{
          float:left;
          padding:5px;
          margin:3px;
          background-color:transparent;
          width:230px;
          height:150px;
     }
     .imagem{
          margin-top:5px;
          margin-bottom:10px;
          cursor:pointer;
     }


     label.filebutton {
          width:120px;
          height:0px;
          overflow:hidden;
          position:relative;
          background-color:transparent;
     }

     label span input {
          z-index: 999;
          line-height: 0;
          font-size: 50px;
          position: absolute;
          top: -2px;
          left: -700px;
          opacity: 0;
          filter: alpha(opacity = 0);
          -ms-filter: "alpha(opacity=0)";
          cursor: pointer;
          _cursor: hand;
          margin: 0;
          padding:0;
     }
     form{
          overflow-x:hidden;
          overflow-y:auto;
     }
  

</style>
    
</head>

<body id="main_body"  style="background:#fff">
     <div id="aguarde" name="aguarde" align="center"  style="width:100%;height:150%;top:0px;left:0px; background:transparent;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);z-index:2000;visibility:hidden;position:absolute;" >								
        <img id="imgAguarde" name="imgAguarde" src="figuras/aguarde.png" width="100px"  border="0" style="position:relative;top:50%" ></img>
    </div>
    
     <form id="formListFile" style="height: expression( this.scrollHeight < 420 ? '420px' :' auto' );padding:0px;background: #fff;border-left:3px solid #1473e6;border-right:3px solid #1473e6;border-bottom:3px solid #1473e6;border-top:3px solid #1473e6;" 
     name="formListFile" style="width:714px" class="appnitro" enctype="multipart/form-data" method="post" >
        
          <input type="hidden" id="acao" name="acao" value="">
          <input type="hidden" id="imagemDel" name="imagemDel" value="">
          <input type="hidden" id="insp" name="insp" value="">
          <input type="hidden" id="grupo" name="grupo" value="">
          <input type="hidden" id="item" name="item" value="">
          <input type="hidden" id="editor" name="editor" value="">
          <input type="hidden" id="dir" name="dir" value="">
          
          <h1 style="background: #1473e6;width:100%;height:12px;color:#fff;font-size:14px;border:4px solid #fff">
          <cfif '#url.editor#' eq 'Melhoria'>
               <cfif '#limiteImagens#' is false >
                    <div style="position:absolute;top:25px;left:20px">Clique para enviar uma imagem ao servidor:</div>
                    <label class="filebutton">
                         <img src="Figuras/uploadpictures.png"/>
                         <cfif '#url.editor#' neq 'Melhoria' >
                         
                              <span><input type="file" id="uploadFile" name="uploadFile"  onchange="EnviarArquivoOrientacoes();"></span>
                         <cfelse>
                              <span><input type="file" id="uploadFile" name="uploadFile" onchange="EnviarArquivoAvaliacoes();"></span>
                         </cfif>
                    </label>
               <cfelse>
                    <div style="left:20px">O n�mero m�ximo de imagens enviadas ao servidor para este item foi atingido.</div>
                    <input type="file" id="uploadFile" name="uploadFile" style="position:absolute;left:1000px"/>
               </cfif>
               <cfelse>
               
                    <div style="position:absolute;top:25px;left:20px">Clique para enviar uma imagem ao servidor:</div>
                    <label class="filebutton">
                         <img src="Figuras/uploadpictures.png"/>
                         <cfif '#url.editor#' neq 'Melhoria' >
                              <span><input type="file" id="uploadFile" name="uploadFile"  onchange="EnviarArquivoOrientacoes();"></span>
                         <cfelse>
                              <span><input type="file" id="uploadFile" name="uploadFile" onchange="EnviarArquivoAvaliacoes();"></span>
                         </cfif>
                    </label>
               </cfif>
          </h1>
          <cfif isDefined("uploadResult")>
               <cfif listFindNoCase(acceptExtensions, uploadResult.serverFileExt)>
                  <cfset  upload="#uploadResult.serverFile#">
                         <cfset localDate = now() > 
                         <cfset data = localDate.getTime()>
                         <cfset nomeArquivo = '#replace(uploadResult.serverFile,' ','_','all')#'>
                         <cfset nomeArquivo = '#data#_#nomeArquivo#'>

                    <cfif '#uploadResult.serverFileExt#' eq 'gif'> 
                         <cffile action="move" source="#uploadResult.serverFile#" destination="#imagesPath#/#nomeArquivo#" />
                         <cfimage source="#imagesPath#/#nomeArquivo#" name="myImage"> 
                    <cfelse>
                         <cffile action="move" source="#uploadResult.serverFile#" destination="#imagesPath#/TEMP.png" />
                         <cfimage source="#imagesPath#/TEMP.png" name="myImage" >  

                         <cfif ImageGetHeight(myImage) gt 500 or ImageGetWidth(myImage) gt 500>
                              <cfset ImageSetAntialiasing(myImage,"on")>
                              <cfset ImageScaleToFit(myImage,"","500")>
                         </cfif>
                         <cfimage source="#myImage#" action="convert" destination="#imagesPath#/#nomeArquivo#" overwrite = "true" >
                         <cffile action="delete" file="#imagesPath#/TEMP.png" /> 
                    </cfif>

               <cfelse>
<!---                     <p><span class="exibir" style="background:color;color:#fff;font-size:14px">ERRO: O tipo de imagem deve ser: gif, jpeg, jpg ou png.</span></p> --->
                    <script language="JavaScript">
                         <cfif '#form.dir#' eq 'imagens'>
                              var erro = "ERRO: O tipo de imagem deve ser: gif, jpeg, jpg ou png.";
                              alert(erro);
                         <cfelse>
                              var erro = "ERRO: O tipo de imagem deve ser: gif, jpg e png.";
                              alert(erro);
                         </cfif>     
                    </script>
                    <cffile action="delete" file="#uploadResult.serverFile#" />
               </cfif>
          </cfif>
          <cfif isDefined('form.grupo') >

               <cfdirectory action="list" directory="#imagesPath#" recurse="false" listinfo="name" name="myList" sort = "datelastmodified Desc" filter="*.png|*.jpg|*.jpeg|*.gif">
               <cfif '#url.editor#' neq 'Melhoria' and '#myList.RecordCount#' eq 0> 
                    <div align="left" style="margin-left:3px;margin-right:137px;margin-top:9px;color:#1473e6;float:left"><cfoutput>Nenhuma imagem encontrada.</cfoutput></div>
                    <div align="right" style="margin-top:6px;">
                         <a type="button" onclick="return MudaPasta()" href="#" class="botaoCad" style="background:#1473e6;color:#fff;font-size:12px;padding:5px">
                         <cfif '#form.dir#' eq 'icones'>Viasualizar Imagens<cfelse>Visualizar Icones</cfif></a> 
                    </div>
               </cfif>

               <cfif '#myList.RecordCount#' gt 0> 
                    <div style="background: #1473e6;height:38px">
                         <cfif '#myList.RecordCount#' eq 1> 
                              <div align="left" style="margin-left:3px;margin-right:137px;margin-top:9px;color:#fff;float:left"><cfoutput>#myList.RecordCount# imagem</cfoutput></div>
                         <cfelse>
                              <div align="left" style="margin-left:3px;margin-right:137px;margin-top:9px;color:#fff;float:left"><cfoutput>#myList.RecordCount# imagens</cfoutput></div>
                         </cfif>
                         
                         <cfif '#url.editor#' neq 'Melhoria' >
                              <div align="center" style="float:left;margin-right:0px;margin-top:9px;color:#fff;">
                                   <input type="radio" id="imgEsquerda" name="imgAlinhamento" value="left">
                                   <label for="html">Esquerda</label>
                                   <input type="radio" id="imgCentro" name="imgAlinhamento" value="center" checked>
                                   <label for="css">Centro</label>
                                   <input type="radio" id="imgDireita" name="imgAlinhamento" value="right">
                                   <label for="javascript">Direita</label>
                              </div>
                              <div align="right" style="margin-top:6px;">
                                   <a type="button" onclick="return MudaPasta()" href="#" class="botaoCad" style="background:#1473e6;color:#fff;font-size:12px;padding:5px">
                                   <cfif '#form.dir#' eq 'icones'>Viasualizar Imagens<cfelse>Visualizar Icones</cfif></a> 
                              </div>
                         </cfif>
                    </div>
                    <div align="center" style="margin-top:3px">
                    
                        <cfoutput  query="myList">
                              <cfset dir =''>
                              <cfif '#url.editor#' neq 'Melhoria' >
                                   <cfif '#form.dir#' eq 'imagens'>
                                        <cfset dir = 'IMAGENS_ORIENTACOES/#form.grupo#_#form.item#/#myList.name#' >
                                   <cfelse>
                                        <cfset dir = 'IMAGENS_ICONES/#myList.name#' >
                                   </cfif> 
                              <cfelse>
                                   <cfset dir = 'IMAGENS_AVALIACOES/#form.insp#_#form.grupo#_#form.item#/#myList.name#' >
                              </cfif>

                              <cfimage source="#dir#" name="myImage">
                              <cfset info=ImageInfo(myImage)>
                              <cfset larguraImg = "#info.width#">
                              <cfset alturaImg = "#info.height#">  
                              <cfset ImageSetAntialiasing(myImage,"on")>
                              <cfif '#form.dir#' eq 'imagens'>
                                   <cfset ImageScaleToFit(myImage,240,120)>
                              <cfelse>
                                   <cfset ImageScaleToFit(myImage,80,40)>
                              </cfif>

                              <div align="center" class="divImagem" style="cursor:pointer;text-align:center; <cfif '#form.dir#' eq 'icones'>width:110px;height:55px</cfif>"  >
                                   <cfimage alt="#myList.name#" source="#myImage#" action="WriteToBrowser" onclick="InsereImagem('#info.source#', #larguraImg#)">
                                   <cfif '#form.dir#' eq 'imagens'>
                                        <div align="center" onclick="ExcluirImagem('#info.source#','#myList.name#')" style="position:relative;top:0px;">
                                             <img src="icones/lixeiraRosa.png" style="cursor:pointer" alt="Clique para excluir esta imagem" width="17" height="17" border="0"></img>
                                        </div>
                                   </cfif>
                              </div>
                           
                        </cfoutput>
                    </div>
               </cfif>
          </cfif>  
     </form>    
<body>
<script language="JavaScript">
     function GrupoNaoDefinido(){
         
          <cfoutput>
          <cfif '#url.editor#' neq 'Melhoria' >
                   
                    <cfif isDefined('form.grupo')>
                         return true;
                    <cfelse>
                         aguarde();
                         var grupo = '1';
                         var item = '1';
                    
                         var edt = '#url.editor#';
                         var dir = '#url.dir#';
                    
                         document.getElementById('grupo').value = grupo;
                         document.getElementById('item').value = item;
                         document.getElementById('editor').value = edt;
                         document.getElementById('dir').value = dir;

                         setTimeout('javascript:formListFile.submit();',500);
                    </cfif>
          <cfelse>
               <cfif isDefined('form.insp')>
                    return true;
               <cfelse>
                    aguarde();
                    var insp = window.opener.document.getElementById('ninsp').value;
                    var grupo = window.opener.document.getElementById('ngrup').value;
                    var item = window.opener.document.getElementById('nitem').value;
                    <cfoutput>
                         var edt = '#url.editor#';
                         var dir = '#url.dir#';
                    </cfoutput>
                    document.getElementById('insp').value = insp;
                    document.getElementById('grupo').value = grupo;
                    document.getElementById('item').value = item;
                    document.getElementById('editor').value = edt;
                    document.getElementById('dir').value = dir;

                    setTimeout('javascript:formListFile.submit();',2000);
                   
               </cfif>
          </cfif>

          </cfoutput>
     }

</script>
</html>

