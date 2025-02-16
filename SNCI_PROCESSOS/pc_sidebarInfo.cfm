<!-- Início do componente do Sidebar -->
<style>
    /* Estilos do Sidebar com efeito vidro fosco */
    #importantSidebar {
        position: fixed;
        top: 60px;
        left: 600px;
        right: 0;
        height: 100%;
        background: rgba(255, 255, 255, 0.5); /* fundo translúcido */
        backdrop-filter: blur(10px); /* efeito de vidro fosco */
        border-left: 2px solid #ddd;
        box-shadow: -2px 0 5px rgba(0,0,0,0.1);
        padding: 15px;
        overflow-y: auto;
        transform: translateX(100%);
        transition: transform 0.3s ease;
        z-index: 1050;
    }
    #importantSidebar.open {
        transform: translateX(0);
    }
    /* Estilos do botão de toggle */
    #toggleSidebar {
        position: fixed;
        top: 70px;
        right: 0;
        background: linear-gradient(to right, #D10000, #FF0000);
        color: #fff;
        border: none;
        padding: 5px 10px;
        border-radius: 5px 0 0 5px;
        cursor: pointer;
        z-index: 1100;
        display: flex;
        align-items: center;
        transition: left 0.3s ease, right 0.3s ease;
    }
    #toggleSidebar:hover {
        background: linear-gradient(to right, #FF0000, #D10000);
    }
    .icon-container {
        position: relative;
        display: inline-block;
        margin-right: 5px;
    }
    .dash-circle {
        display: inline-block;
        width: 30px;
        height: 30px;
        border: 2px dashed #fff;
        border-radius: 50%;
        animation: spin 2s linear infinite;
        position: relative;
        margin-top: 3px;
    }
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    .circle-text {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-size: 18px;
        font-weight: bold;
        color: #fff;
        animation: counter-spin 2s linear infinite;
    }
    @keyframes counter-spin {
        from { transform: translate(-50%, -50%) rotate(0deg); }
        to { transform: translate(-50%, -50%) rotate(-360deg); }
    }
</style>

<!-- HTML do Sidebar e Botão -->
<div id="importantSidebar">
    <!-- Conteúdo dinâmico ou estático -->
    <div id="formFaqDiv"></div>
</div>
<button id="toggleSidebar">
    <span class="icon-container">
        <span class="dash-circle">
            <span class="circle-text">?</span>
        </span>
    </span>
    Informações Importantes
</button>

<!-- jQuery para controlar o comportamento do Sidebar -->
<script>
    $(document).ready(function(){
        $("#toggleSidebar").click(function(e){
            e.stopPropagation();
            $("#importantSidebar").toggleClass("open");
            // Garante que o botão permaneça à direita
            $("#toggleSidebar").css({ left: "auto", right: "0" });
        });
        $(document).on("click", function(e){
            if($("#importantSidebar").hasClass("open") &&
               $(e.target).closest("#importantSidebar, #toggleSidebar").length === 0){
                   $("#importantSidebar").removeClass("open");
                   $("#toggleSidebar").css({ left: "auto", right: "0" });
            }
        });
    });
    
    // Adiciona função mostraFormFaq() para carregar os FAQs
    function mostraFormFaq(){
        $.ajax({
            type: "post",
            url: "cfc/pc_cfcFaqs.cfc",
            data: { method: "formFaqIndex" },
            dataType: "text"  // Lida com JSON ou HTML
        })
        .done(function(response) {
            if(!response || response.trim() === ""){
                $('#formFaqDiv').html("<p>Nenhum FAQ retornado pelo servidor.</p>");
                $("#toggleSidebar").hide();
                return;
            }
            var result;
            try {
                result = JSON.parse(response);
            } catch(e) {
                result = { type: "text", content: response };
            }
            $('#formFaqDiv').html(result.content);
            var faqCount = $('#formFaqDiv .card-title').length;
            if (faqCount > 0) {
                $("#toggleSidebar").show();
                $("#toggleSidebar").contents().filter(function(){ return this.nodeType === 3; }).remove();
                if(faqCount === 1){
                    $("#toggleSidebar").append(" Informação Importante");
                } else {
                    $("#toggleSidebar").append(" Informações Importantes");
                }
            } else {
                $("#toggleSidebar").hide();
            }
        })
        .fail(function(xhr, ajaxOptions, thrownError) {
            $('#modalOverlay').delay(1000).hide(0, function() {
                $('#modalOverlay').modal('hide');
            });
            $('#modal-danger').modal('show');
            $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:');
            $('#modal-danger').find('.modal-body').text(thrownError);
        });
    }
</script>
<!-- Fim do componente do Sidebar -->
