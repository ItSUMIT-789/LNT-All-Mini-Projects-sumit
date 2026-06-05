#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

DEPLOYMENT_NAME="my-app"

echo ""
echo -e "${BOLD}============================================================${NC}"
echo -e "${BOLD}   Kubernetes Self-Healing Demonstration${NC}"
echo -e "${BOLD}============================================================${NC}"
echo ""

echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${BOLD}Step 1: Current pods before deletion${NC}"
echo "------------------------------------------------------------"
kubectl get pods -l app=${DEPLOYMENT_NAME} -o wide
echo ""

echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${BOLD}Step 2: Selecting a random running pod...${NC}"

RUNNING_PODS=$(kubectl get pods -l app=${DEPLOYMENT_NAME} --field-selector=status.phase=Running -o jsonpath='{.items[*].metadata.name}')

if [ -z "$RUNNING_PODS" ]; then
    echo -e "${RED}ERROR: No running pods found for deployment '${DEPLOYMENT_NAME}'.${NC}"
    echo "Make sure you have applied the deployment first:"
    echo "  kubectl apply -f deployment.yaml"
    exit 1
fi

POD_ARRAY=($RUNNING_PODS)
POD_COUNT=${#POD_ARRAY[@]}
RANDOM_INDEX=$((RANDOM % POD_COUNT))
TARGET_POD=${POD_ARRAY[$RANDOM_INDEX]}

echo -e "  Found ${GREEN}${POD_COUNT}${NC} running pod(s)."
echo -e "  Randomly selected: ${RED}${TARGET_POD}${NC}"
echo ""

echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${BOLD}Step 3: Pod UIDs before deletion${NC}"
echo "------------------------------------------------------------"
kubectl get pods -l app=${DEPLOYMENT_NAME} -o custom-columns="NAME:.metadata.name,STATUS:.status.phase,AGE:.metadata.creationTimestamp,UID:.metadata.uid"
echo ""

echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${BOLD}Step 4: Deleting pod '${TARGET_POD}'...${NC}"
echo "------------------------------------------------------------"
kubectl delete pod "${TARGET_POD}"
echo -e "${RED}  Pod '${TARGET_POD}' deleted!${NC}"
echo ""

echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${BOLD}Step 5: Watching self-healing in action...${NC}"
echo "------------------------------------------------------------"
echo -e "${YELLOW}Kubernetes will now automatically recreate the deleted pod.${NC}"
echo -e "${YELLOW}Watch the STATUS column — you will see a new pod appear.${NC}"
echo ""

for i in 1 2 3 4 5 6; do
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} Checking pods (attempt $i/6)..."
    kubectl get pods -l app=${DEPLOYMENT_NAME} -o wide
    echo ""

    READY_COUNT=$(kubectl get deployment ${DEPLOYMENT_NAME} -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    DESIRED_COUNT=$(kubectl get deployment ${DEPLOYMENT_NAME} -o jsonpath='{.spec.replicas}')

    if [ "$READY_COUNT" == "$DESIRED_COUNT" ] && [ "$i" -gt 1 ]; then
        echo -e "${GREEN}✅ All ${DESIRED_COUNT} replicas are Running and Ready!${NC}"
        break
    fi

    sleep 5
done

echo ""
echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${BOLD}Step 6: Final pod state after self-healing${NC}"
echo "------------------------------------------------------------"
kubectl get pods -l app=${DEPLOYMENT_NAME} -o wide
echo ""

echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${BOLD}Deployment status:${NC}"
kubectl get deployment ${DEPLOYMENT_NAME}
echo ""

echo -e "${BOLD}============================================================${NC}"
echo -e "${GREEN}  Self-Healing Demo Complete!${NC}"
echo -e "${BOLD}============================================================${NC}"
echo ""
echo -e "  ${BOLD}What happened:${NC}"
echo -e "    1. We had ${DESIRED_COUNT} replicas running."
echo -e "    2. We deleted pod '${TARGET_POD}'."
echo -e "    3. The ReplicaSet controller detected the missing pod."
echo -e "    4. Kubernetes automatically created a new pod to maintain"
echo -e "       the desired state of ${DESIRED_COUNT} replicas."
echo ""
echo -e "  ${BOLD}Key Takeaway:${NC}"
echo -e "    Kubernetes ensures the actual state always matches the"
echo -e "    desired state defined in the Deployment spec."
echo ""
