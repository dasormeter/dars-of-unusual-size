#!/bin/bash

START=1
END=$1

#roughly 20000 per templates, multiple by 20000 to get approximate size of dar

echo "module Iou where"
 
for (( i=$START; i<=$END; i++ ))
do
   echo "type IouCid$i = ContractId Iou$i"
done


for (( i=$START; i<=$END; i++ ))
do
   echo "
template Iou$i
  with
    issuer : Party
    owner : Party
    currency : Text
    amount : Decimal
    observers : [Party]
  where
    ensure amount > 0.0

    signatory issuer, owner

    observer observers

    controller owner can

      -- Split the IOU by dividing the amount.
      Iou_Split$i : (IouCid$i, IouCid$i)
         with
          splitAmount: Decimal
        do
          let restAmount = amount - splitAmount
          splitCid <- create this with amount = splitAmount
          restCid <- create this with amount = restAmount
          return (splitCid, restCid)

      -- Merge two IOUs by aggregating their amounts.
      Iou_Merge$i : IouCid$i
        with
          otherCid: IouCid$i
        do
          otherIou <- fetch otherCid
          -- Check the two IOU's are compatible
          assert (
            currency == otherIou.currency &&
            owner == otherIou.owner &&
            issuer == otherIou.issuer
            )
          -- Retire the old Iou
          archive otherCid
          -- Return the merged Iou
          create this with amount = amount + otherIou.amount

      Iou_Transfer$i : ContractId IouTransfer$i
        with
          newOwner : Party
        do create IouTransfer$i with iou = this; newOwner

      Iou_AddObserver$i : IouCid$i
        with
          newObserver : Party
        do create this with observers = newObserver :: observers

      Iou_RemoveObserver$i : IouCid$i
        with
          oldObserver : Party
        do create this with observers = filter (/= oldObserver) observers

template IouTransfer$i
  with
    iou : Iou$i
    newOwner : Party
  where
    signatory iou.issuer, iou.owner

    controller iou.owner can
      IouTransfer_Cancel$i : IouCid$i
        do create iou

    controller newOwner can
      IouTransfer_Reject$i : IouCid$i
        do create iou

      IouTransfer_Accept$i : IouCid$i
        do
          create iou with
            owner = newOwner
            observers = []
"
done
