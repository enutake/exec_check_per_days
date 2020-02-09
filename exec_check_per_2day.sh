#!/bin/bash
# 2日に一度実行するように判断する

#基本は[[ $( expr $( date +\%j ) \% 2 ) != 0 ]]
#しかし、年始に調整する必要がある　前年が平年で今日の日付が1/1だったとき、確認用ファイルを1,0で書き換える
# 奇数日実行だとすると、[...,365,001,...]は2連続実行してしまう
# 実行条件を偶数日実行に切り替える？
# [平年,平年]、[平年,閏年]は切り替える必要あり。[閏年,平年]は切り替える必要なし。
#閏年、平年判定が必要
TODAY=`date '+%m/%d'`
INITIAL_DATE="01/01"
LASTYEAR=`date '+%Y'`
ODD_EVEN_CHECK_FILEPATH="./odd_even_check_txt"

: "メイン処理" && {
    : "チェックファイルの準備" && {
        if [[ -e ${ODD_EVEN_CHECK_FILEPATH} ]]; then
            if [[ -s ${ODD_EVEN_CHECK_FILEPATH} ]]; then
                echo 1 > ${ODD_EVEN_CHECK_FILEPATH}
            fi
        else
            touch ${ODD_EVEN_CHECK_FILEPATH}
            echo 1 > ${ODD_EVEN_CHECK_FILEPATH}
        fi
    }
    : "閏年・平年の条件変更" && {
        
        : "昨年が閏年か否かの確認" && {
            if [[ `expr ${LASTYEAR} % 4` -eq 0 ]]; then
                if [[ `expr ${LASTYEAR} % 100` -eq 0 ]]; then
                    if [[ `expr ${LASTYEAR} % 400` -eq 0 ]]; then
                        LASTYEAR_IS_NOT_LEAPYEAR=0
                    else
                        LASTYEAR_IS_NOT_LEAPYEAR=1
                    fi
                else
                    LASTYEAR_IS_NOT_LEAPYEAR=1
                fi
            else
                LASTYEAR_IS_NOT_LEAPYEAR=0
            fi
        }

        : "条件に合う場合、奇数日・偶数日実行を切り替える" && {
            if [[ ${TODAY} = ${INITIAL_DATE} && ${LASTYEAR_IS_NOT_LEAPYEAR} -eq 0 ]]; then
                LAST_ODD_EVEN_CHECK=`cat ${ODD_EVEN_CHECK_FILEPATH}`
                if [[ ${LAST_ODD_EVEN_CHECK} -eq 1 ]]; then
                    echo 0 > ${ODD_EVEN_CHECK_FILEPATH}
                else
                    echo 1 > ${ODD_EVEN_CHECK_FILEPATH}
                fi
            fi
        }

    }

    : "実行チェック" && {
        ODD_EVEN_CHECK=`cat ${ODD_EVEN_CHECK_FILEPATH}`
        if [[ $( expr $( date +\%j ) \% 2 ) = ${ODD_EVEN_CHECK} ]]; then
            exit(0)
        else
            exit(1)
        fi
    }
}
