
#define _QNX_SOURCE /* sleep() */

#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <libyang/libyang.h>
#include <sysrepo.h>
//#include <vapi/vapi.h>
#include <sysrepo/xpath.h>
#include <sysrepo/values.h>
//#include "vpp.h"

/* session of our plugin, can be used until cleanup is called */
sr_session_ctx_t *sess;
/* structure holding all the subscriptions */
sr_subscription_ctx_t *subscription;

//vapi_ctx_t g_vapi_ctx_instance=NULL;

volatile pthread_t ondemand_tid;

volatile unsigned int packets;


static void *
ondemand_thread(void *arg)
{
    int rc;
    //unsigned int desired_temperature;

    //sr_val_t *val;

    sr_val_t *val = NULL;

    rc = sr_new_values(1, &val);
    sr_val_set_xpath(&val[0], "/ondemand:route-miss/prefix");
    sr_val_set_str_data(&val[0], SR_STRING_T,  "2000::1");

    (void)arg;
    while (ondemand_tid) {
        sleep(1);
	//SRP_LOG_DBG("Query loop");
        //GoInt p = Query();
        //if(p != packets) {
                rc = sr_event_notif_send(sess, "/ondemand:route-miss", val, 1, 0, 0);
                if (rc != SR_ERR_OK) {
                    SRP_LOG_ERR("Ondemand: route-miss notification generation failed: %s.", sr_strerror(rc));
                }
        //}
        //packets = p;
    }

    return NULL;

}

static int
ondemand_add_route_cb(sr_session_ctx_t *session, uint32_t sub_id, const char *path, const sr_val_t *input,
        const size_t input_cnt, sr_event_t event, uint32_t request_id, sr_val_t **output, size_t *output_cnt,
        void *private_data)
{
    (void)session;
    (void)sub_id;
    (void)path;
    (void)input;
    (void)input_cnt;
    (void)event;
    (void)request_id;
    (void)output;
    (void)output_cnt;
    (void)private_data;

    SRP_LOG_DBG("ONDEMAND. RPC add-route received");

   
    char* p = input[0].data.binary_val;
    char* d = input[1].data.binary_val; 
    //GoString pref = {p,9};
    //GoString dest = {d,4};
    //CreatePolicy(pref,dest);
    return SR_ERR_OK;
}


int
sr_plugin_init_cb(sr_session_ctx_t *session, void **private_data)
{
    int rc;
    pthread_t tid;

    (void)private_data;

    packets = 0;
    /* subscribe for insert-food RPC calls */
    rc = sr_rpc_subscribe(session, "/ondemand:add-route", ondemand_add_route_cb, NULL, 0, SR_SUBSCR_CTX_REUSE, &subscription);
    if (rc != SR_ERR_OK) {
        goto error;
    }

    sess = session;
    if(ondemand_tid == 0) {
        rc = pthread_create((pthread_t *)&ondemand_tid, NULL, ondemand_thread, NULL);
        if (rc != 0) {
            goto sys_error;
        }
    } else {
        tid = ondemand_tid;
        ondemand_tid = 0;
        rc = pthread_join(tid, NULL);
        if (rc != 0) {
            goto sys_error;
        }

    }

    /*rc = ondemand_connect_vpp();
    if (SR_ERR_OK != rc) {
        return SR_ERR_INTERNAL;
    }*/
    /* sysrepo/plugins.h provides an interface for logging */
    SRP_LOG_DBG("On demand: plugin initialized successfully.");
    return SR_ERR_OK;

error:
    SRP_LOG_ERR("On demand: plugin initialization failed: %s.", sr_strerror(rc));
    sr_unsubscribe(subscription);
    return rc;
sys_error:
  //  sr_free_val(val);
    SRP_LOG_ERR("On demand: On deman config change callback failed: %s.", strerror(rc));
    return SR_ERR_OPERATION_FAILED;
}

void
sr_plugin_cleanup_cb(sr_session_ctx_t *session, void *private_data)
{
    (void)session;
    (void)private_data;

    /* nothing to cleanup except freeing the subscriptions */
    sr_unsubscribe(subscription);
    SRP_LOG_DBG("OVEN: Oven plugin cleanup finished.");
}


