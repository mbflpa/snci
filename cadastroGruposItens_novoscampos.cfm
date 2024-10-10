<cfprocessingdirective pageEncoding ="utf-8"> 
<!doctype html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>SNCI NOVOS CAMPOS</title>
        <style>
          .exibir-select {
            background-color: #dcdcdc;
            font-family: verdana, arial, sans-serif;
            font-size: 15px;
          }
        </style>
    </head>
    <body onload="">
        <header>	
            <h1>Tela de testes Local para Novos campos no SNCI</h1>
            <div class="clear"></div>	
        </header>
        <section>	
            <div>
                <h3>Adequando tela aos múltiplos navegadores</h3>
            </div>
            <p id="msg"></p>
        </section>
            <br><br>
            <div class="container">
              <div id="mensagem">Mensagem (para testes)</div>
                <div class="row">            
                  <div class="col">
                    <div id="exibir-classifcontrole" class="exibir-select"></div>
                    <label for="Classificação do Controle" ><strong>Classificação do Controle</strong></label>
                    <br>
                    <select id="classifcontrole" multiple="multiple">
                    </select>
                  </div>
                  <br>  
                  <div class="col">
                    <label for="Controle Testado" ><strong>Controle Testado</strong></label>
                    <br>                  
                    <textarea  name="controletestado" id="controletestado" cols="166" rows="2" wrap="VIRTUAL" class="form" placeholder="Pode existir mais de um controle testado por item"></textarea>
                  </div>
                </div>
                <br>
                <div class="row">
                      <div class="col">
                      <div id="exibir-categcontrole" class="exibir-select"></div>
                      <label for="Categoria do Controle" ><strong>Categoria do Controle</strong></label>
                      <br>
                      <select id="categcontrole" multiple="multiple">
                      </select>
                    </div>
                </div>
                <br>
                <div class="row">
                    <div class="col">
                      <label for="Risco Identificado" ><strong>Risco Identificado</strong></label>
                      <div id="riscoidentif-outros"><textarea name="riscoidentificadooutros" id="riscoidentificadooutros" cols="166" rows="2" wrap="VIRTUAL" class="form" placeholder="Outros - Informar Descrição aqui."></textarea></div>
                      <br>
<!---                     <div id="exibir-riscoidentificado" class="exibir-select"></div> --->
                    <select id="riscoidentificado">
                    </select>
                  </div>
              </div>
                <br>       
                <label class="exibir-select"><strong>Tipo de Avaliação</strong>
                  <br>
                    <div class="row">
                      <div class="col">
                        <label for="macroprocesso" ><strong>Macroprocesso</strong></label>
                        <br>
                        <select id="macroprocesso" >
                        </select>
                      </div>
                      <br>
                      <div class="col">
                        <label for="macroprocesson1" ><strong>Macroprocesson1</strong></label>
                        <div id="macroprocesson1-naoseaplica"><textarea name="macroprocesson1naoseaplica" id="macroprocesson1naoseaplica" cols="166" rows="2" wrap="VIRTUAL" class="form" placeholder="Não se aplica - Informar Descrição aqui."></textarea></div>
                        <br>
                        <select id="macroprocesson1" ><input type="checkbox" id="cd_macroprocesson1" name="cd_macroprocesson1" title="">Não se Aplica
                        </select>
                      </div>
                      <br>
                      <div class="col">
                        <label for="macroprocesson2" ><strong>Macroprocesson2</strong></label>
                        <br>
                        <select id="macroprocesson2" >
                        </select>
                      </div>
                      <br>
                      <div class="col">
                        <label for="macroprocesson3" ><strong>Macroprocesson3</strong></label>
                        <div id="macroprocesson3-outros"><textarea name="macroprocesson3outros" id="macroprocesson3outros" cols="166" rows="2" wrap="VIRTUAL" class="form" placeholder="Outros - Informar Descrição aqui."></textarea></div>
                        <br>
                        <select id="macroprocesson3"><input type="checkbox" id="cd_macroprocesson3" name="cd_macroprocesson3" title="">Outros
                        </select>
                      </div>
                    </div>
                </label>         
                <br>
                <div class="row">
                    <div class="col">
                    <label for="Gestor do Processo" ><strong>Gestor do Processo</strong>( Lista de Departamentos)</label>
                    <br>
                    <select id="gestorprocesso">
                    </select>
                  </div>
              </div>
              <br>
              <div class="row">
                    <div class="col">
                    <div id="exibir-objetivoestrategico" class="exibir-select"></div>
                    <label for="Objetivo Estratégico" ><strong>Objetivo Estratégico</strong></label>
                    <br>
                    <select id="objetivoestrategico" multiple="multiple">
                    </select>
                  </div>
              </div>   
              <br>
              <div class="row">
                    <div class="col">
                    <div id="exibir-riscoestrategico" class="exibir-select"></div>
                    <label for="Risco Estratégico" ><strong>Risco Estratégico</strong></label>
                    <br>
                    <select id="riscoestrategico" multiple="multiple">
                    </select>
                  </div>
              </div> 
              <br>
              <div class="row">
                    <div class="col">
                      <div id="exibir-indicadorestrategico" class="exibir-select"></div>
                      <label for="Indicador Estratégico" ><strong>Indicador Estratégico</strong></label>
                      <br>
                      <select id="indicadorestrategico" multiple="multiple">
                      </select>
                  </div>
              </div> 
              <br>
              <div class="row">
                    <div class="col">
                      <label for="Coso 2013" ><strong>COSO 2013 - Componente</strong></label>
                      <br>
                      <select id="componentecoso">
                      </select>
                  </div>
              </div>  
              <br>
              <div class="row">
                    <div class="col">
                      <label for="Princípios COSO" ><strong>Princípios COSO 2013</strong></label>
                      <br>
                      <select id="principioscoso">
                      </select>
                  </div>
              </div>                                                                                     
                <br>
            </div>
    </body>   
    <script type="text/javascript" src="public/jquery-3.2.1.min.js"></script> 
    <script type="text/javascript" src="public/jquery-ui/jquery-ui.min.js"></script> 
    
      <script type="text/javascript" src="public/axios.min.js"></script>
   <!--- 
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script> --->
        

    <script type="text/javascript"> 

        // Quando o dom for carregado              
        //busca o macroprocesso
        $(function(e){
  //alert('Dom inicializado!');
/*
      //      const myFirstPromise = new Promise((resolve, reject) => {
              setTimeout(() => {
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                  method: "classifctrl"
                  }
                })
                .then(data =>{
                  let prots = ''
                  //console.log(data.data)
                  //console.log(data.data.indexOf("COLUMNS"));
                  var vlr_ini = data.data.indexOf("COLUMNS");
                  var vlr_fin = data.data.length
                  vlr_ini = (vlr_ini - 2);
                // console.log('valor inicial: ' + vlr_fin);
                  const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                  //console.log(json);
                  const dados = json.DATA;
                  dados.map((ret) => {
                  prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
                });
                  $("#classifcontrole").html(prots);
                  $("#mensagem").html(prots);
                }) 
                //resolve("Success!"); // Yay! Everything went well!
              }, 350);
        //    });
        //    myFirstPromise.then((successMessage) => {
        //      console.log(`Yay! ${successMessage}`);
        //    });
*/  
 // buscar classificação do controle
// setTimeout(() => {
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "classifctrl"
              }
            })
            .then(data =>{
                  let prots = ''
                  //console.log(data.data)
                  //console.log(data.data.indexOf("COLUMNS"));
                  var vlr_ini = data.data.indexOf("COLUMNS");
                  var vlr_fin = data.data.length
                  vlr_ini = (vlr_ini - 2);
                // console.log('valor inicial: ' + vlr_fin);
                  const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                  //console.log(json);
                  const dados = json.DATA;
                  dados.map((ret) => {
                  prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
                });
              $("#classifcontrole").html(prots);
              //$("#mensagem").html(prots);
            })   
//}, 350);    
          
            //busca da categoria   
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "categcontrole"
              }
            })
            .then(data =>{
                let prots = ''
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#categcontrole").html(prots);
              //$("#mensagem").html(prots);
            })  

            //buscar riscos identificado     
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "riscoidentificado"
              }
            })
            .then(data =>{
                let prots = ''
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#riscoidentificado").html(prots);
              //$("#mensagem").html(prots);
            })  
               
            // buscar macroprocesso   
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "macroprocesso"
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#macroprocesso").html(prots);
              //$("#mensagem").html(prots);
            })  
                 
            // buscar gestor do processo  
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "gestorprocesso"
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#gestorprocesso").html(prots);
              //$("#mensagem").html(prots);
            })   
              
            //busca da objetivo estrategico     
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "objetivoestrategico"
              }
            })
            .then(data =>{
              let prots = '';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#objetivoestrategico").html(prots);
              //$("#mensagem").html(prots);
            })  
             
            //busca da risco estrategico  
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "riscoestrategico"
              }
            })
            .then(data =>{
                let prots = ''
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#riscoestrategico").html(prots);
              //$("#mensagem").html(prots);
            })  
              
            //busca da indicador estrategico      
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "indicadorestrategico"
              }
            })
            .then(data =>{
                let prots = ''
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#indicadorestrategico").html(prots);
              //$("#mensagem").html(prots);
            })  
             //componentecoso2013 
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "componentecoso"
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#componentecoso").html(prots);
              //$("#mensagem").html(prots);
            })                                                  
            processosajustes('abertura');   
 /**/                                                  
//===============================================
        }) 
        // fim abertura do DOM       
//===============================================                                                               
        //classificação do controle 
        $('#classifcontrole').click(function() {
              $("#exibir-classifcontrole").hide();
              var auxselect = '';
              $('#classifcontrole  > option:selected').each(function() {
               // auxselect += ($(this).text() + ' ' + $(this).val());
               if(auxselect == '') {
                  auxselect += $(this).text();
               }else{
                  auxselect += '#' + $(this).text();
               }
              }); 
              if(auxselect != '') { $("#exibir-classifcontrole").show();}
              $("#exibir-classifcontrole").html(auxselect);
        });    
        // Categoria do controle testado
        $('#categcontrole').click(function() {
              $("#exibir-categcontrole").hide();
              var auxselect = '';
              $('#categcontrole  > option:selected').each(function() {
               // auxselect += ($(this).text() + ' ' + $(this).val());
               if(auxselect == '') {
                  auxselect += $(this).text();
               }else{
                  auxselect += '#' + $(this).text();
               }
              }); 
              if(auxselect != '') { $("#exibir-categcontrole").show();}
              $("#exibir-categcontrole").html(auxselect);
        });  
        $('#riscoidentificado').click(function() {
          $("#riscoidentif-outros").hide();
            var auxselect = '';
            $('#riscoidentificado  > option:selected').each(function() {
              auxselect += $(this).text();
            })
            if(auxselect == 'Outros'){
              $("#riscoidentif-outros").show();
            }
        });
//****************************************************************************        
        //buscar macroporcessoN1
        $('#macroprocesso').change(function(e){
          let prots = '<option value="" selected>---</option>';
          $("#macroprocesson1").html(prots);
          $("#macroprocesson2").html(prots);
          $("#macroprocesson3").html(prots);
          processosajustes('macroprocesso');
          var PCN1MAPCID = $(this).val();          
          axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "macroprocesson1",
              PCN1MAPCID: PCN1MAPCID
              }
          })
          .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#macroprocesson1").html(prots);
              //$("#mensagem").html(prots);
          })  
        })     
        // inicio macroprocesson1 -  Não se aplica
        $('#cd_macroprocesson1').click(function(){
          $("#macroprocesson1-naoseaplica").hide();
          $("#macroprocesson3-outros").hide();
          $("#cd_macroprocesson3").prop("checked", false);
          $("#cd_macroprocesson3").attr('disabled', true);
          var prots = '<option value="" selected>---</option>';
          $("#macroprocesson1").html(prots);
          $("#macroprocesson2").html(prots);
          $("#macroprocesson3").html(prots);
         // processosajustes('macroprocesson1');
          if($(this).is(':checked')) {
            $("#macroprocesson1").attr('disabled', true);
            $("#macroprocesson2").attr('disabled', true);
            $("#macroprocesson3").attr('disabled', true);
            $("#macroprocesson1-naoseaplica").show();
          }else{
            $("#macroprocesson1").attr('disabled', false);
            //realizar nova busca e preecher o macroprocesson1
            var PCN1MAPCID = $("#macroprocesso").val();
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "macroprocesson1",
              PCN1MAPCID: PCN1MAPCID
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
                $("#macroprocesson1").html(prots);
                //$("#mensagem").html(prots);
            })           
          }
        })       
        // fim macroprocesson1-Não se aplica     
        //buscar macroporcessoN2
        $('#macroprocesson1').change(function(e){
            let prots = '<option value="" selected>---</option>';
            $("#macroprocesson3").html(prots);
            $("#macroprocesson3-outros").hide();
            $("#macroprocesson2").html(prots);
            processosajustes('macroprocesson1');
            var PCN1MAPCID = $("#macroprocesso").val();
            var PCN1ID = $(this).val();
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "macroprocesson2",
              PCN1MAPCID: PCN1MAPCID,
              PCN1ID: PCN1ID
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
                $("#macroprocesson2").html(prots);
                //$("#mensagem").html(prots);
            })  
        }) 
        //final buscar macroporcessoN2   
        //inicio buscar macroprocessoN3
        $('#macroprocesson2').change(function(e){
            $("#cd_macroprocesson3").attr('disabled', false);
            $("#macroprocesson3-outros").hide();
            let prots = '<option value="" selected>---</option>';
            $("#macroprocesson3").attr('disabled', false);
            $("#macroprocesson3").html(prots);
            processosajustes('macroprocesson2');
            var PCN3PCN2PCN1MAPCID = $("#macroprocesso").val();
            var PCN3PCN2PCN1ID = $("#macroprocesson1").val();
            var PCN3PCN2ID = $(this).val();
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "macroprocesson3",
              PCN3PCN2PCN1MAPCID: PCN3PCN2PCN1MAPCID,
              PCN3PCN2PCN1ID: PCN3PCN2PCN1ID,
              PCN3PCN2ID: PCN3PCN2ID
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
                $("#macroprocesson3").html(prots);
                //$("#mensagem").html(prots);
            }) 
 
        })   
        //final buscar macroprocessoN3  
        // inicio macroprocesson3-Outros
        //==============================
        $('#cd_macroprocesson3').click(function(){
          $("#macroprocesson3-outros").hide();
          let prots = '<option value="" selected>---</option>';
          $("#macroprocesson3").html(prots);
          if($(this).is(':checked')) {
            $("#macroprocesson3").attr('disabled', true);
            $("#macroprocesson3-outros").show();
          }else{
            $("#macroprocesson3").attr('disabled', false);
            //realizar nova busca e preecher o macroprocesson1
            var PCN3PCN2PCN1MAPCID = $("#macroprocesso").val();
            var PCN3PCN2PCN1ID = $("#macroprocesson1").val();
            var PCN3PCN2ID = $("#macroprocesson2").val();
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "macroprocesson3",
              PCN3PCN2PCN1MAPCID: PCN3PCN2PCN1MAPCID,
              PCN3PCN2PCN1ID: PCN3PCN2PCN1ID,
              PCN3PCN2ID: PCN3PCN2ID
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
                $("#macroprocesson3").html(prots);
                //$("#mensagem").html(prots);
            }) 
         
          }
     })       
     // fim macroprocesson3-Outros                                       
   
 
        //buscar o principios do coso passando filtro do componentecoso
        $('#componentecoso').change(function(e){
          let prots = '<option value="" selected>---</option>';
            $("#principioscoso").attr('disabled', false);
            var PRCSCPCSID = $(this).val();
            axios.get("CFC/grupoitem.cfc",{
              params: {
              method: "principioscoso",
              PRCSCPCSID: PRCSCPCSID
              }
            })
            .then(data =>{
                let prots = '<option value="" selected>---</option>';
                var vlr_ini = data.data.indexOf("COLUMNS");
                var vlr_fin = data.data.length
                vlr_ini = (vlr_ini - 2);
                const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
                const dados = json.DATA;
                dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
                $("#principioscoso").html(prots);
                //$("#mensagem").html(prots);
            }) 
        })  

        function processosajustes(a){
          if (a == 'abertura'){
          //  alert(a);
              $("#riscoidentif-outros").hide();
              $("#macroprocesson1-naoseaplica").hide();
              $("#macroprocesson3-outros").hide();
              $("#exibir-objetivoestrategico").hide();
              $("#cd_macroprocesson1").attr('disabled', true);
              $("#cd_macroprocesson3").attr('disabled', true);
              $("#principioscoso").attr('disabled', true);
              $("#macroprocesson1").attr('disabled', true);
              $("#macroprocesson2").attr('disabled', true);
              $("#macroprocesson3").attr('disabled', true);
          }
          if (a == 'macroprocesso'){
         //   alert(a);
            $("#cd_macroprocesson1").attr('disabled', false);
            $("#cd_macroprocesson1").prop("checked", false);
            $("#cd_macroprocesson3").attr('disabled', true);
            $("#cd_macroprocesson3").prop("checked", false);
            $("#macroprocesson1-naoseaplica").hide();
            $("#macroprocesson3-outros").hide();
            $("#macroprocesson1").attr('disabled', false);
            $("#macroprocesson2").attr('disabled', true);
            $("#macroprocesson3").attr('disabled', true);
          }
          if (a == 'macroprocesson1'){
           // alert(a);
            $("#macroprocesson2").attr('disabled', false);
            $("#cd_macroprocesson3").attr('disabled', true);
            $("#cd_macroprocesson3").prop("checked", false);
            $("#macroprocesson3-outros").hide();
            $("#macroprocesson3").attr('disabled', true);
          }  
          if (a == 'macroprocesson2'){
           // alert(a);
            $("#cd_macroprocesson3").attr('disabled', false);
            $("#cd_macroprocesson3").prop("checked", false);
            $("#macroprocesson3-outros").hide();
            $("#macroprocesson3").attr('disabled', false);
          }                   
        } 
</script>
</html>