#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

DEPLOYMENT_NAME="my-app"
SERVICE_NAME="my-service"
EXPECTED_REPLICAS=3

PASS=0
FAIL=0

check_result() {
    local test_name="$1"
    local result="$2"
    if [ "$result" == "PASS" ]; then
        echo -e "  ${GREEN}✅ PASS${NC} — ${test_name}"
        ((PASS++))
    else
        echo -e "  ${RED}❌ FAIL${NC} — ${test_name}"
        ((FAIL++))
    fi
}

echo ""
echo -e "${BOLD}============================================================${NC}"
echo -e "${BOLD}   Kubernetes Deployment Verification${NC}"
echo -e "${BOLD}============================================================${NC}"
echo -e "${CYAN}  Timestamp: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo ""

echo -e "${BOLD}1. Checking Deployment '${DEPLOYMENT_NAME}'...${NC}"
echo "------------------------------------------------------------"
if kubectl get deployment ${DEPLOYMENT_NAME} &>/dev/null; then
    kubectl get deployment ${DEPLOYMENT_NAME}
    check_result "Deployment '${DEPLOYMENT_NAME}' exists" "PASS"
else
    check_result "Deployment '${DEPLOYMENT_NAME}' exists" "FAIL"
fi
echo ""

echo -e "${BOLD}2. Checking Replica Count...${NC}"
echo "------------------------------------------------------------"
ACTUAL_REPLICAS=$(kubectl get deployment ${DEPLOYMENT_NAME} -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
echo "  Expected replicas: ${EXPECTED_REPLICAS}"
echo "  Actual replicas:   ${ACTUAL_REPLICAS}"
if [ "$ACTUAL_REPLICAS" == "$EXPECTED_REPLICAS" ]; then
    check_result "Replica count is ${EXPECTED_REPLICAS}" "PASS"
else
    check_result "Replica count is ${EXPECTED_REPLICAS} (got ${ACTUAL_REPLICAS})" "FAIL"
fi

READY_REPLICAS=$(kubectl get deployment ${DEPLOYMENT_NAME} -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
echo "  Ready replicas:    ${READY_REPLICAS}"
if [ "$READY_REPLICAS" == "$EXPECTED_REPLICAS" ]; then
    check_result "All ${EXPECTED_REPLICAS} replicas are Ready" "PASS"
else
    check_result "All ${EXPECTED_REPLICAS} replicas are Ready (got ${READY_REPLICAS})" "FAIL"
fi
echo ""

echo -e "${BOLD}3. Checking Service '${SERVICE_NAME}'...${NC}"
echo "------------------------------------------------------------"
if kubectl get svc ${SERVICE_NAME} &>/dev/null; then
    kubectl get svc ${SERVICE_NAME}
    check_result "Service '${SERVICE_NAME}' exists" "PASS"
else
    check_result "Service '${SERVICE_NAME}' exists" "FAIL"
fi
echo ""

echo -e "${BOLD}4. Checking NodePort Configuration...${NC}"
echo "------------------------------------------------------------"
SERVICE_TYPE=$(kubectl get svc ${SERVICE_NAME} -o jsonpath='{.spec.type}' 2>/dev/null || echo "UNKNOWN")
echo "  Service Type: ${SERVICE_TYPE}"
if [ "$SERVICE_TYPE" == "NodePort" ]; then
    check_result "Service type is NodePort" "PASS"
else
    check_result "Service type is NodePort (got ${SERVICE_TYPE})" "FAIL"
fi

NODE_PORT=$(kubectl get svc ${SERVICE_NAME} -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "N/A")
echo "  Assigned NodePort: ${NODE_PORT}"
if [ "$NODE_PORT" != "N/A" ] && [ -n "$NODE_PORT" ]; then
    check_result "NodePort is assigned (port ${NODE_PORT})" "PASS"
else
    check_result "NodePort is assigned" "FAIL"
fi
echo ""

echo -e "${BOLD}5. Checking Pod Status...${NC}"
echo "------------------------------------------------------------"
kubectl get pods -l app=${DEPLOYMENT_NAME} -o wide
echo ""

RUNNING_PODS=$(kubectl get pods -l app=${DEPLOYMENT_NAME} --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
echo "  Running pods: ${RUNNING_PODS}/${EXPECTED_REPLICAS}"
if [ "$RUNNING_PODS" -ge "$EXPECTED_REPLICAS" ]; then
    check_result "All pods are in Running state" "PASS"
else
    check_result "All pods are in Running state (${RUNNING_PODS}/${EXPECTED_REPLICAS} running)" "FAIL"
fi
echo ""

TOTAL=$((PASS + FAIL))
echo -e "${BOLD}============================================================${NC}"
echo -e "${BOLD}   Verification Summary${NC}"
echo -e "${BOLD}============================================================${NC}"
echo -e "  Total checks: ${TOTAL}"
echo -e "  ${GREEN}Passed: ${PASS}${NC}"
echo -e "  ${RED}Failed: ${FAIL}${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}🎉 ALL CHECKS PASSED — Deployment is healthy!${NC}"
else
    echo -e "  ${RED}${BOLD}⚠️  SOME CHECKS FAILED — Review the output above.${NC}"
fi
echo ""
