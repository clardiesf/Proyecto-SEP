/** Librerías **/
#include "xtmrctr.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xparameters.h"
#include <string.h>
#include "sleep.h"

/** Instancia de Controladores **/
XScuGic INTCInst;
XTmrCtr TMRInst0;
XTmrCtr TMRInst1;

/** Contadores para temporizadores **/
static int tmr_count0 = 500000000;
static int tmr_count1 = 700000000;
static char state_flag[30];  // Arreglo de caracteres para almacenar el estado actual

/** Macros de configuración **/
#define INTC_DEVICE_ID           XPAR_PS7_SCUGIC_0_DEVICE_ID
#define TMR_DEVICE_ID_0          XPAR_TMRCTR_0_DEVICE_ID
#define TMR_DEVICE_ID_1          XPAR_TMRCTR_1_DEVICE_ID
#define INTC_TMR_INTERRUPT_ID_0  XPAR_FABRIC_AXI_TIMER_0_INTERRUPT_INTR
#define INTC_TMR_INTERRUPT_ID_1  XPAR_FABRIC_AXI_TIMER_1_INTERRUPT_INTR

/** Prototipos de funciones **/
static void TMR_Intr_Handler0(void *baseaddr_p);
static void TMR_Intr_Handler1(void *baseaddr_p);
static int IntcInitFunction(u16 DeviceId, XTmrCtr *TmrInstancePtr, XTmrCtr *TmrInstancePtr1);

/** Funciones **/

// Manejador de interrupción para el temporizador 0
void TMR_Intr_Handler0(void *data) {
    strcpy(state_flag, "Timer 0 interruption process");
    xil_printf("Estado: %s\n", state_flag);  // Imprime el estado en la consola

    if (XTmrCtr_IsExpired(&TMRInst0, 0)) {
        XTmrCtr_Reset(&TMRInst0, 0);  // Resetear el temporizador 0
        XTmrCtr_Start(&TMRInst0, 0);
    }

    // Regresar estado a código principal
    strcpy(state_flag, "Main Code process");
    xil_printf("Estado: %s\n", state_flag);  // Imprime el estado en la consola
}

// Manejador de interrupción para el temporizador 1
void TMR_Intr_Handler1(void *data) {
    strcpy(state_flag, "Timer 1 interruption process");
    xil_printf("Estado: %s\n", state_flag);  // Imprime el estado en la consola

    if (XTmrCtr_IsExpired(&TMRInst1, 0)) {
        XTmrCtr_Reset(&TMRInst1, 0);  // Resetear el temporizador 1
        XTmrCtr_Start(&TMRInst1, 0);
    }

    // Regresar estado a código principal
    strcpy(state_flag, "Main Code process");
    xil_printf("Estado: %s\n", state_flag);  // Imprime el estado en la consola
}

// Configuración de interrupciones
int IntcInitFunction(u16 DeviceId, XTmrCtr *TmrInstancePtr, XTmrCtr *TmrInstancePtr1) {
    XScuGic_Config *IntcConfig;
    int status;

    // Inicialización del controlador de interrupciones
    IntcConfig = XScuGic_LookupConfig(DeviceId);
    status = XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Asignación de prioridades
    XScuGic_SetPriorityTriggerType(&INTCInst, INTC_TMR_INTERRUPT_ID_0, 0x20, 0x1);
    XScuGic_SetPriorityTriggerType(&INTCInst, INTC_TMR_INTERRUPT_ID_1, 0x28, 0x1);

    // Conexión de interrupciones a sus respectivos manejadores
    status = XScuGic_Connect(&INTCInst, INTC_TMR_INTERRUPT_ID_0, (Xil_ExceptionHandler)TMR_Intr_Handler0, (void *) TmrInstancePtr);
    if (status != XST_SUCCESS) return XST_FAILURE;

    status = XScuGic_Connect(&INTCInst, INTC_TMR_INTERRUPT_ID_1, (Xil_ExceptionHandler)TMR_Intr_Handler1, (void *) TmrInstancePtr1);
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Habilitar interrupciones de temporizadores
    XScuGic_Enable(&INTCInst, INTC_TMR_INTERRUPT_ID_0);
    XScuGic_Enable(&INTCInst, INTC_TMR_INTERRUPT_ID_1);

    return XST_SUCCESS;
}

/** Main **/
int main(void) {
    int status;

    // Inicializar el temporizador 0
    status = XTmrCtr_Initialize(&TMRInst0, TMR_DEVICE_ID_0);
    if (status != XST_SUCCESS) return XST_FAILURE;
    XTmrCtr_SetHandler(&TMRInst0, (XTmrCtr_Handler) TMR_Intr_Handler0, &TMRInst0);
    XTmrCtr_SetResetValue(&TMRInst0, 0, tmr_count0);
    XTmrCtr_SetOptions(&TMRInst0, 0, XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION);

    // Inicializar el temporizador 1
    status = XTmrCtr_Initialize(&TMRInst1, TMR_DEVICE_ID_1);
    if (status != XST_SUCCESS) return XST_FAILURE;
    XTmrCtr_SetHandler(&TMRInst1, (XTmrCtr_Handler) TMR_Intr_Handler1, &TMRInst1);
    XTmrCtr_SetResetValue(&TMRInst1, 0, tmr_count1);
    XTmrCtr_SetOptions(&TMRInst1, 0, XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION);

    // Configurar el controlador de interrupciones
    status = IntcInitFunction(INTC_DEVICE_ID, &TMRInst0, &TMRInst1);
    if (status != XST_SUCCESS) return XST_FAILURE;

    strcpy(state_flag, "Main Code process");
    xil_printf("Estado inicial: %s\n", state_flag);  // Imprime el estado inicial

    // Ciclo principal
    while (1) {
        strcpy(state_flag, "Main Code process");
        xil_printf("Estado: %s\n", state_flag);  // Imprime el estado en el ciclo principal
        sleep(1);  // Agregar un retardo para ver el mensaje en la consola
    }

    return 0;
}
